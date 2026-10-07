import { Controller, Get, Req } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Controller('impact')
export class ImpactController {
  constructor(private readonly prisma: PrismaService) {}

  @Get('me')
  async me(@Req() req: any) {
    const userId = req.user.sub;
    const [payments, offers, cases, completed] = await Promise.all([
      this.prisma.transaction.aggregate({ where: { userId, status: 'SUCCEEDED' }, _sum: { amountMinor: true }, _count: { _all: true } }),
      this.prisma.helpOffer.count({ where: { userId, status: 'ACTIVE' } }),
      this.prisma.helpCase.count({ where: { ownerId: userId } }),
      this.prisma.helpCase.count({ where: { ownerId: userId, status: 'COMPLETED' } }),
    ]);
    return { contributions: payments._count._all, amountMinor: payments._sum.amountMinor ?? 0, activeOffers: offers, requestsCreated: cases, requestsCompleted: completed };
  }
}
