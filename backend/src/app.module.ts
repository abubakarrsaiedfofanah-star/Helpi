import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';

import { AuthController } from './auth/auth.controller';
import { AuthService } from './auth/auth.service';
import { JwtAuthGuard } from './auth/jwt.guard';
import { CasesController } from './cases/cases.controller';
import { CasesService } from './cases/cases.service';
import { CommunicationsController } from './communications/communications.controller';
import { CommunicationsService } from './communications/communications.service';
import { CountryOperationsController } from './country-operations.controller';
import { CountryOperationsService } from './country-operations.service';
import { CountriesController } from './countries.controller';
import { CurrencyController } from './currency/currency.controller';
import { FraudGraphController } from './fraud/fraud-graph.controller';
import { FraudGraphService } from './fraud/fraud-graph.service';
import { FraudController } from './fraud/fraud.controller';
import { FraudService } from './fraud/fraud.service';
import { GlobalController } from './global/global.controller';
import { HealthController } from './health.controller';
import { AdminController } from './admin/admin.controller';
import { AdminService } from './admin/admin.service';
import { MessagesController } from './messages/messages';
import { MessagesGateway } from './messages/messages.gateway';
import { NetworkController } from './network/network.controller';
import { NotificationsController } from './notifications/notifications';
import { PrismaService } from './prisma.service';
import { PublicController } from './public/public.controller';
import { ReferralsController } from './referrals.controller';
import { ReportsController } from './reports/reports';
import { RolesGuard } from './roles.guard';
import { SafeguardingController } from './safeguarding/safeguarding.controller';
import { SafeguardingService } from './safeguarding/safeguarding.service';
import { AccountSecurityService } from './security/account-security.service';
import { SecurityController } from './security/security.controller';
import { SecurityService } from './security/security.service';
import { PushController } from './push/push.controller';
import { PushService } from './push/push.service';
import { UsersController } from './users/users.controller';

@Module({
  imports: [
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 60 }]),
    JwtModule.register({}),
  ],
  controllers: [
    HealthController,
    AuthController,
    CasesController,
    UsersController,
    SecurityController,
    CountriesController,
    MessagesController,
    ReportsController,
    NotificationsController,
    CurrencyController,
    ReferralsController,
    FraudController,
    FraudGraphController,
    AdminController,
    PushController,
    CommunicationsController,
    SafeguardingController,
    PublicController,
    NetworkController,
    GlobalController,
    CountryOperationsController,
  ],
  providers: [
    PrismaService,
    AuthService,
    CasesService,
    SecurityService,
    AccountSecurityService,
    FraudService,
    FraudGraphService,
    MessagesGateway,
    PushService,
    CommunicationsService,
    SafeguardingService,
    CountryOperationsService,
    AdminService,
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule {}
