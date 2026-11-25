import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';

import { CountryOperationsService } from '../country-operations.service';
import { PrismaService } from '../prisma.service';
import { CreateCaseDto } from './dto';
import { CaseCategory } from './dto';

const publicCaseFields = {
  id: true,
  category: true,
  goalMinor: true,
  currency: true,
  countryCode: true,
  city: true,
  status: true,
  publicIdentityMode: true,
  publicDisplayName: true,
  createdAt: true,
};

@Injectable()
export class CasesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly countryOps: CountryOperationsService,
  ) {}

  async list(q?: string, category?: string, country?: string) {
    const query = q?.trim();
    const matchingCategory = query
      ? Object.values(CaseCategory).find(
          (value) => value.toLowerCase() === query.toLowerCase().replace(/\s+/g, '_'),
        )
      : undefined;
    const requests = await this.prisma.helpCase.findMany({
      where: {
        status: 'PUBLISHED',
        ...(category ? { category: category as any } : {}),
        ...(country ? { countryCode: country.toUpperCase() } : {}),
        ...(query
          ? {
              OR: [
                { city: { contains: query, mode: 'insensitive' } },
                ...(matchingCategory ? [{ category: matchingCategory as any }] : []),
              ],
            }
          : {}),
      },
      select: {
        ...publicCaseFields,
        owner: {
          select: {
            publicIdentityMode: true,
            publicAlias: true,
            name: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    return requests.map((request) => this.withPublicIdentity(request));
  }

  mine(userId: string) {
    return this.prisma.helpCase.findMany({
      where: { ownerId: userId },
      select: publicCaseFields,
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(userId: string, dto: CreateCaseDto) {
    const country = await this.countryOps.get(dto.countryCode);
    if (country.enabled === false) {
      throw new ForbiddenException('Requests are unavailable in this country.');
    }
    if (!country.currencies.includes(dto.currency.toUpperCase())) {
      throw new ForbiddenException('This currency is not available in this country.');
    }

    return this.prisma.helpCase.create({
      data: {
        title: 'Financial support request',
        description: 'Contact directly to discuss support.',
        category: dto.category,
        goalMinor: dto.goalMinor,
        currency: dto.currency.toUpperCase(),
        countryCode: dto.countryCode.toUpperCase(),
        city: dto.city,
        ownerId: userId,
        status: 'PUBLISHED',
        publicIdentityMode: dto.publicIdentityMode || 'REAL_NAME',
        publicDisplayName: dto.publicDisplayName?.trim() || null,
      },
      select: publicCaseFields,
    });
  }

  async get(id: string) {
    const request = await this.prisma.helpCase.findUnique({
      where: { id },
      select: {
        ...publicCaseFields,
        owner: {
          select: {
            publicIdentityMode: true,
            publicAlias: true,
            name: true,
          },
        },
      },
    });
    if (!request || request.status !== 'PUBLISHED') {
      throw new NotFoundException('Request not found.');
    }
    return this.withPublicIdentity(request);
  }

  private withPublicIdentity<T extends {
    publicIdentityMode: string | null;
    owner: { publicIdentityMode: string; publicAlias: string | null; name: string };
  }>(request: T) {
    const { owner, ...publicRequest } = request;
    const identityMode = request.publicIdentityMode ?? owner.publicIdentityMode;
    const publicOwner = identityMode === 'ANONYMOUS'
      ? { publicIdentityMode: 'ANONYMOUS' }
      : identityMode === 'ALIAS'
        ? { publicIdentityMode: 'ALIAS', publicAlias: owner.publicAlias }
        : { publicIdentityMode: 'REAL_NAME', name: owner.name };
    return { ...publicRequest, owner: publicOwner };
  }

  async updateStatus(userId: string, id: string, status: 'PAUSED' | 'DRAFT') {
    const request = await this.prisma.helpCase.findUnique({ where: { id } });
    if (!request) throw new NotFoundException('Request not found.');
    if (request.ownerId !== userId) throw new ForbiddenException();
    return this.prisma.helpCase.update({
      where: { id },
      data: { status },
      select: publicCaseFields,
    });
  }
}
