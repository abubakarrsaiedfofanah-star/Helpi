import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { createHash } from 'crypto';
import { PrismaService } from '../prisma.service';

const allowedTransitions: Record<string,string[]> = {
  CREATED: ['PROCESSING','FAILED'],
  PROCESSING: ['SUCCEEDED','FAILED'],
  SUCCEEDED: ['REFUNDED'],
  FAILED: [],
  REFUNDED: [],
};

@Injectable()
export class PaymentsService {
  constructor(private prisma: PrismaService) {}

  async payoutDestination(userId:string) {
    const row=await this.prisma.payoutDestination.findFirst({where:{userId},orderBy:{createdAt:'desc'}});
    return row?{countryCode:row.countryCode,method:row.method,displayLast4:row.displayLast4,status:row.status}:null;
  }

  async createIntent(userId: string, b: {caseId:string; amountMinor:number; currency:string; purpose?:string; idempotencyKey?:string}) {
    const c = await this.prisma.helpCase.findUnique({ where:{id:b.caseId} });
    if (!c) throw new NotFoundException('Case not found.');
    if (c.status !== 'PUBLISHED') {
      throw new BadRequestException('This case is not ready for payment.');
    }
    const destination=await this.prisma.payoutDestination.findFirst({where:{userId:c.ownerId,countryCode:c.countryCode}});
    if(!destination?.encryptedDestination) throw new BadRequestException('The recipient has not added a private payout method yet.');
    if(destination.status==='BLOCKED'||destination.status==='PENDING_REVIEW') throw new BadRequestException('This recipient payout method needs review before payments can be prepared.');
    if (!Number.isSafeInteger(b.amountMinor) || b.amountMinor <= 0 || b.amountMinor > 1000000000) {
      throw new BadRequestException('Invalid amount.');
    }
    const currency = String(b.currency || '').trim().toUpperCase();
    if (!/^[A-Z]{3}$/.test(currency)) throw new BadRequestException('Invalid currency.');
    if (c.countryCode !== 'KE' || currency !== 'KES') throw new BadRequestException('Payments are currently available only for Kenyan requests in KES.');

    // Fail closed: never create a fake/demo payment when no real provider is configured.
    const provider = await this.prisma.paymentProvider.findFirst({
      where:{countryCode:c.countryCode, enabled:true, settlementCurrency:currency},
      orderBy:{createdAt:'asc'}
    });
    if (!provider) throw new BadRequestException('No verified payment method is available for this country and currency.');

    if (b.idempotencyKey) {
      const existing = await this.prisma.transaction.findUnique({where:{idempotencyKey:b.idempotencyKey}});
      if (existing) {
        if (existing.userId !== userId || existing.caseId !== c.id || existing.amountMinor !== b.amountMinor || existing.currency !== currency) {
          throw new ConflictException('Payment request does not match the original request.');
        }
        return this.publicTransaction(existing);
      }
    }

    const tx = await this.prisma.transaction.create({data:{
      userId, caseId:c.id, amountMinor:b.amountMinor, currency, purpose:b.purpose?.slice(0,500),
      status:'CREATED', idempotencyKey:b.idempotencyKey,
    }});
    await this.prisma.paymentAttempt.create({data:{transactionId:tx.id,providerId:provider.id,status:'CREATED'}});
    return {...this.publicTransaction(tx), provider:provider.name, paymentAttemptRequired:true};
  }

  private publicTransaction(tx:any) {
    return {id:tx.id,status:tx.status,amountMinor:tx.amountMinor,currency:tx.currency};
  }

  listMine(userId:string) {
    return this.prisma.transaction.findMany({where:{userId},orderBy:{createdAt:'desc'},take:100,select:{id:true,caseId:true,amountMinor:true,currency:true,status:true,createdAt:true,updatedAt:true,blockedReason:true}});
  }

  async webhook(b:{transactionId:string; status:'PROCESSING'|'SUCCEEDED'|'FAILED'; providerReference?:string; amountMinor?:number; currency?:string; eventType?:string; providerId?:string}) {
    if (!b.transactionId || !b.providerReference || !b.eventType) throw new BadRequestException('Incomplete payment event.');
    const tx = await this.prisma.transaction.findUnique({where:{id:b.transactionId}});
    if (!tx) throw new NotFoundException('Transaction not found.');
    if (b.amountMinor !== undefined && b.amountMinor !== tx.amountMinor) return this.reject(tx.id,'Provider amount mismatch.');
    if (b.currency && b.currency.toUpperCase() !== tx.currency) return this.reject(tx.id,'Provider currency mismatch.');

    const payloadHash = createHash('sha256').update(JSON.stringify(b)).digest('hex');
    try {
      await this.prisma.paymentWebhookEvent.create({data:{providerReference:b.providerReference,eventType:b.eventType,payloadHash}});
    } catch {
      // Duplicate provider event: idempotent success, never apply it twice.
      return this.publicTransaction(tx);
    }

    if (tx.providerReference && tx.providerReference !== b.providerReference) return this.reject(tx.id,'Transaction already has a different provider reference.');
    if (!(allowedTransitions[tx.status] || []).includes(b.status)) return this.reject(tx.id,`Invalid payment state transition: ${tx.status} -> ${b.status}.`);

    const updated = await this.prisma.$transaction(async db => {
      const next = await db.transaction.update({where:{id:tx.id},data:{status:b.status,providerReference:b.providerReference}});
      await db.paymentWebhookEvent.update({where:{providerReference_eventType:{providerReference:b.providerReference,eventType:b.eventType}},data:{processed:true,processedAt:new Date()}});
      await db.auditLog.create({data:{userId:tx.userId,action:`PAYMENT_${b.status}`,metadata:{transactionId:tx.id,providerReference:b.providerReference,eventType:b.eventType}}});
      return next;
    });
    return this.publicTransaction(updated);
  }

  private async reject(transactionId:string, reason:string) {
    const tx = await this.prisma.transaction.update({where:{id:transactionId},data:{status:'FAILED',blockedReason:reason}});
    return {...this.publicTransaction(tx), rejected:true};
  }
}
