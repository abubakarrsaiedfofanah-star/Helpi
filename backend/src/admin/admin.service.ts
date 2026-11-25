import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { CaseStatus, Prisma, UserRole, UserStatus } from '@prisma/client';

import { PrismaService } from '../prisma.service';

const userAdminFields = {
  id: true,
  name: true,
  email: true,
  role: true,
  status: true,
  supportGroup: true,
  countryCode: true,
  createdAt: true,
  lastLoginAt: true,
} satisfies Prisma.UserSelect;

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async dashboard() {
    const [users, activeUsers, pendingUsers, suspendedUsers, publishedRequests,
      openReports, safeguarding, organizations, requestGroups] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { status: 'ACTIVE' } }),
      this.prisma.user.count({ where: { status: 'PENDING' } }),
      this.prisma.user.count({ where: { status: 'SUSPENDED' } }),
      this.prisma.helpCase.count({ where: { status: 'PUBLISHED' } }),
      this.prisma.report.count({ where: { status: { in: ['OPEN', 'IN_REVIEW'] } } }),
      this.prisma.safeguardingCase.count({
        where: { status: { in: ['OPEN', 'TRIAGED', 'INVESTIGATING'] } },
      }),
      this.prisma.organization.count(),
      this.prisma.helpCase.groupBy({
        by: ['category'],
        where: { status: 'PUBLISHED' },
        _count: { _all: true },
      }),
    ]);
    return {
      users,
      activeUsers,
      pendingUsers,
      suspendedUsers,
      publishedRequests,
      openReports,
      safeguarding,
      organizations,
      requestGroups,
    };
  }

  async users(search = '', status?: UserStatus, page = 1, pageSize = 25) {
    const safePage = Math.max(1, Math.floor(Number.isFinite(page) ? page : 1));
    const safePageSize = Math.min(
      100,
      Math.max(1, Math.floor(Number.isFinite(pageSize) ? pageSize : 25)),
    );
    const term = search.trim();
    const where: Prisma.UserWhereInput = {
      ...(status ? { status } : {}),
      ...(term
        ? {
            OR: [
              { name: { contains: term, mode: 'insensitive' } },
              { email: { contains: term, mode: 'insensitive' } },
              { countryCode: { contains: term, mode: 'insensitive' } },
            ],
          }
        : {}),
    };
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: userAdminFields,
        orderBy: { createdAt: 'desc' },
        skip: (safePage - 1) * safePageSize,
        take: safePageSize,
      }),
      this.prisma.user.count({ where }),
    ]);
    return { items, total, page: safePage, pageSize: safePageSize };
  }

  async setUserStatus(
    adminId: string,
    targetId: string,
    status: UserStatus,
    ipAddress?: string,
    userAgent?: string,
  ) {
    const allowedStatuses: UserStatus[] = [
      UserStatus.ACTIVE,
      UserStatus.SUSPENDED,
      UserStatus.DISABLED,
    ];
    if (!allowedStatuses.includes(status)) {
      throw new BadRequestException('Choose an allowed account status.');
    }
    if (adminId === targetId && status !== UserStatus.ACTIVE) {
      throw new ForbiddenException('You cannot disable your own administrator account.');
    }
    const target = await this.prisma.user.findUnique({
      where: { id: targetId },
      select: { id: true, role: true, status: true },
    });
    if (!target) throw new NotFoundException('Account not found.');
    if (target.status === UserStatus.PENDING && status === UserStatus.ACTIVE) {
      throw new ForbiddenException('Pending accounts must complete email verification first.');
    }
    if (target.role === UserRole.ADMIN && status !== UserStatus.ACTIVE) {
      const activeAdmins = await this.prisma.user.count({
        where: { role: UserRole.ADMIN, status: UserStatus.ACTIVE },
      });
      if (target.status === UserStatus.ACTIVE && activeAdmins <= 1) {
        throw new ConflictException('At least one active administrator must remain.');
      }
    }

    return this.prisma.$transaction(async (transaction) => {
      const updated = await transaction.user.update({
        where: { id: targetId },
        data: { status },
        select: userAdminFields,
      });
      if (status !== UserStatus.ACTIVE) {
        await transaction.refreshSession.updateMany({
          where: { userId: targetId, revokedAt: null },
          data: { revokedAt: new Date() },
        });
      }
      await transaction.auditLog.create({
        data: {
          userId: adminId,
          action: 'ADMIN_USER_STATUS_CHANGED',
          ipAddress,
          userAgent,
          metadata: { targetUserId: targetId, previousStatus: target.status, status },
        },
      });
      return updated;
    });
  }

  async requests() {
    const requests = await this.prisma.helpCase.findMany({
      where: { status: { in: [CaseStatus.PUBLISHED, CaseStatus.PAUSED] } },
      select: {
        id: true,
        category: true,
        goalMinor: true,
        currency: true,
        countryCode: true,
        city: true,
        publicDisplayName: true,
        publicIdentityMode: true,
        status: true,
        createdAt: true,
        owner: {
          select: { name: true, publicAlias: true, publicIdentityMode: true },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    return requests.map(({ owner, ...request }) => ({
      ...request,
      requesterName:
        request.publicIdentityMode === 'ANONYMOUS'
          ? 'Anonymous member'
          : request.publicDisplayName ||
            (owner.publicIdentityMode === 'ANONYMOUS'
              ? 'Anonymous member'
              : owner.publicIdentityMode === 'ALIAS'
                ? owner.publicAlias || 'Community member'
                : owner.name),
    }));
  }

  async updateRequestStatus(
    adminId: string,
    requestId: string,
    status: 'PUBLISHED' | 'PAUSED',
    ipAddress?: string,
    userAgent?: string,
  ) {
    if (![CaseStatus.PUBLISHED, CaseStatus.PAUSED].includes(status)) {
      throw new BadRequestException('Choose an allowed request status.');
    }
    const current = await this.prisma.helpCase.findUnique({
      where: { id: requestId },
      select: { id: true, status: true },
    });
    if (!current || (current.status !== CaseStatus.PUBLISHED && current.status !== CaseStatus.PAUSED)) {
      throw new NotFoundException('Published request not found.');
    }
    return this.prisma.$transaction(async (transaction) => {
      const updated = await transaction.helpCase.update({
        where: { id: requestId },
        data: { status },
        select: { id: true, category: true, goalMinor: true, currency: true, status: true },
      });
      await transaction.auditLog.create({
        data: {
          userId: adminId,
          action: 'ADMIN_REQUEST_VISIBILITY_CHANGED',
          ipAddress,
          userAgent,
          metadata: { requestId, previousStatus: current.status, status },
        },
      });
      return updated;
    });
  }

  organizations() {
    return this.prisma.organization.findMany({
      select: {
        id: true,
        name: true,
        type: true,
        countryCode: true,
        city: true,
        description: true,
        website: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
      take: 200,
    });
  }

  safetyReports() {
    return this.prisma.report.findMany({
      where: { status: { in: ['OPEN', 'IN_REVIEW'] } },
      select: {
        id: true,
        type: true,
        description: true,
        status: true,
        createdAt: true,
        reporter: { select: { id: true, name: true } },
        case: { select: { id: true, category: true, countryCode: true } },
      },
      orderBy: { createdAt: 'asc' },
      take: 100,
    });
  }

  async updateReportStatus(
    adminId: string,
    reportId: string,
    status: 'IN_REVIEW' | 'RESOLVED' | 'DISMISSED',
    ipAddress?: string,
    userAgent?: string,
  ) {
    const report = await this.prisma.report.findUnique({
      where: { id: reportId },
      select: { id: true, status: true },
    });
    if (!report) throw new NotFoundException('Report not found.');
    const [updated] = await this.prisma.$transaction([
      this.prisma.report.update({ where: { id: reportId }, data: { status } }),
      this.prisma.auditLog.create({
        data: {
          userId: adminId,
          action: 'ADMIN_REPORT_STATUS_CHANGED',
          ipAddress,
          userAgent,
          metadata: { reportId, previousStatus: report.status, status },
        },
      }),
    ]);
    return updated;
  }

  audit() {
    return this.prisma.auditLog.findMany({
      select: {
        id: true,
        action: true,
        ipAddress: true,
        metadata: true,
        createdAt: true,
        user: { select: { name: true, email: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }
}
