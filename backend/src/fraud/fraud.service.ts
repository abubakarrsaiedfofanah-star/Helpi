import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FraudSignalStatus } from '@prisma/client';
@Injectable()
export class FraudService {
  constructor(private prisma: PrismaService) {}
  async scanCase(caseId: string, actorId: string) {
    const c = await this.prisma.helpCase.findUnique({ where: { id: caseId }, select: { id:true, ownerId:true,title:true,description:true,countryCode:true,goalMinor:true,currency:true } });
    if (!c) throw new Error('Case not found');
    const signals:any[]=[];
    const duplicate = await this.prisma.helpCase.findMany({ where:{ id:{not:caseId}, ownerId:c.ownerId, title:{equals:c.title,mode:'insensitive'} }, take:5 });
    if(duplicate.length) signals.push({type:'DUPLICATE_OWNER_TITLE',severity:'HIGH',details:{matches:duplicate.map(x=>x.id)}});
    if(c.goalMinor > 50000000) signals.push({type:'HIGH_VALUE_CASE',severity:'MEDIUM',details:{goalMinor:c.goalMinor,currency:c.currency}});
    if(c.description.length < 40) signals.push({type:'THIN_DESCRIPTION',severity:'LOW',details:{length:c.description.length}});
    for(const s of signals) await this.prisma.fraudSignal.create({data:{caseId,actorId,type:s.type,severity:s.severity,details:s.details}});
    return {caseId,signalCount:signals.length,signals};
  }
  list(status?:string){return this.prisma.fraudSignal.findMany({where:status?{status:status as FraudSignalStatus}:{},orderBy:{createdAt:'desc'},take:200});}
  resolve(id:string,reviewerId:string,status:'REVIEWED'|'DISMISSED'|'CONFIRMED',note?:string){return this.prisma.fraudSignal.update({where:{id},data:{status,resolvedBy:reviewerId,resolvedAt:new Date(),resolutionNote:note}});}
}
