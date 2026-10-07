import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
@Injectable()
export class VerificationService {
  constructor(private prisma: PrismaService) {}
  queue(caseId: string, requesterId: string, reason?: string) { return this.prisma.verificationRequest.create({ data: { caseId, requesterId, reason } }); }
  list(status?: string) { return this.prisma.verificationRequest.findMany({ where: status ? { status: status as any } : undefined, include: { case: { select: { id: true, title: true, countryCode: true, category: true, verificationStatus: true } }, requester: { select: { id: true, name: true, countryCode: true } } }, orderBy: { createdAt: 'asc' }, take: 100 }); }
  async review(id: string, reviewerId: string, status: 'VERIFIED'|'REJECTED'|'NEEDS_MORE_EVIDENCE', reason?: string) {
    const request = await this.prisma.verificationRequest.findUnique({ where: { id } });
    if (!request) throw new NotFoundException('Verification request not found.');
    if (request.status === 'VERIFIED' || request.status === 'REJECTED') throw new BadRequestException('This request has already been finalized.');
    return this.prisma.$transaction(async tx => {
      const vr = await tx.verificationRequest.update({ where: { id }, data: { status, reviewerId, reviewedAt: new Date(), reason } });
      const caseStatus = status === 'VERIFIED' ? 'PUBLISHED' : status === 'REJECTED' ? 'REJECTED' : 'UNDER_REVIEW';
      const c = await tx.helpCase.update({ where: { id: request.caseId }, data: { verificationStatus: status, status: caseStatus, verificationSummary: reason } });
      await tx.auditLog.create({ data: { userId: reviewerId, action: `verification.${status.toLowerCase()}`, metadata: { requestId: id, caseId: c.id } } });
      return vr;
    });
  }
}
