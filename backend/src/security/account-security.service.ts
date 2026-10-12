import { Injectable, ForbiddenException } from '@nestjs/common';
import { createHash } from 'crypto';
import { PrismaService } from '../prisma.service';
import { privateFingerprint, seal } from '../crypto';

@Injectable()
export class AccountSecurityService {
  constructor(private prisma: PrismaService) {}

  deviceHash(userAgent: string, ip: string) {
    return createHash('sha256').update(`${userAgent}|${ip}`).digest('hex');
  }

  async inspectLogin(userId: string, meta: { ip: string; userAgent: string }) {
    const deviceHash = this.deviceHash(meta.userAgent, meta.ip);
    const known = await this.prisma.deviceRegistration.findFirst({ where: { userId, deviceHash } });
    if (!known) {
      await this.prisma.deviceRegistration.create({ data: { userId, deviceHash, platform: this.platform(meta.userAgent) } }).catch(() => undefined);
      await this.prisma.securityEvent.create({
        data: { userId, type: 'NEW_DEVICE_LOGIN', severity: 'MEDIUM', ipAddress: meta.ip, userAgent: meta.userAgent, deviceHash, details: { action: 'login' } }
      });
      await this.prisma.notification.create({
        data: { userId, type: 'SECURITY', title: 'New sign-in', body: 'A new device signed in to your Helpi account.' }
      }).catch(() => undefined);
      return { deviceHash, newDevice: true };
    }
    await this.prisma.deviceRegistration.update({ where: { id: known.id }, data: { lastSeenAt: new Date() } });
    return { deviceHash, newDevice: false };
  }

  async revokeAll(userId: string) {
    await this.prisma.refreshSession.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: new Date() } });
    await this.prisma.securityEvent.create({ data: { userId, type: 'SESSIONS_REVOKED', severity: 'INFO', details: { reason: 'user_requested' } } });
    return { ok: true };
  }

  async createPayoutDestination(userId: string, input: { countryCode: string; method: string; destination: string }) {
    const countryCode=String(input.countryCode||'').toUpperCase();
    const method=String(input.method||'').toUpperCase();
    const destination=String(input.destination||'').replace(/[\s()-]/g,'');
    const user=await this.prisma.user.findUnique({where:{id:userId},select:{countryCode:true}});
    if(countryCode!=='KE'||user?.countryCode!=='KE'||method!=='MPESA'||!/^(?:\+254|254|0)?[17]\d{8}$/.test(destination)) throw new ForbiddenException('Enter a valid Kenyan M-Pesa destination.');
    const normalized=destination.startsWith('+')?destination:`+${destination.startsWith('0')?'254'+destination.slice(1):destination.startsWith('254')?destination:'254'+destination}`;
    const destinationHash = privateFingerprint(normalized);
    const existing = await this.prisma.payoutDestination.findFirst({ where: { userId }, orderBy:{createdAt:'desc'} });
    if (existing && existing.status === 'BLOCKED') throw new ForbiddenException('This payout destination is blocked.');
    const recent = await this.prisma.securityEvent.count({ where: { userId, type: 'NEW_DEVICE_LOGIN', createdAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } } });
    const riskLevel = recent >= 2 ? 'HIGH' : 'LOW';
    const status = riskLevel === 'HIGH' ? 'PENDING_REVIEW' : 'PENDING';
    const data={countryCode,method,destinationHash,encryptedDestination:seal(normalized),displayLast4:normalized.slice(-4),status,riskLevel,blockedAt:null};
    if(existing?.status==='BLOCKED') throw new ForbiddenException('This payout destination is blocked.');
    const row=existing?await this.prisma.payoutDestination.update({where:{id:existing.id},data}):await this.prisma.payoutDestination.create({data:{...data,userId}});
    return { id:row.id,countryCode:row.countryCode,method:row.method,displayLast4:row.displayLast4,status:row.status,riskLevel:row.riskLevel,createdAt:row.createdAt };
  }

  private platform(ua: string) {
    const x = ua.toLowerCase();
    if (x.includes('android')) return 'ANDROID';
    if (x.includes('iphone') || x.includes('ipad')) return 'IOS';
    if (x.includes('windows')) return 'WINDOWS';
    if (x.includes('mac')) return 'MACOS';
    return 'OTHER';
  }
}
