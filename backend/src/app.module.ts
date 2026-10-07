import { GlobalController } from './global/global.controller';
import { CountryOperationsController } from './country-operations.controller';
import { CountryOperationsService } from './country-operations.service';
import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { JwtModule } from '@nestjs/jwt';
import { PrismaService } from './prisma.service';
import { JwtAuthGuard } from './auth/jwt.guard';
import { RolesGuard } from './roles.guard';
import { AuthController } from './auth/auth.controller'; import { AuthService } from './auth/auth.service';
import { CasesController } from './cases/cases.controller'; import { CasesService } from './cases/cases.service';
import { UsersController } from './users/users.controller'; import { SecurityController } from './security/security.controller'; import { SecurityService } from './security/security.service';
import { CountriesController } from './countries.controller'; import { HealthController } from './health.controller';
import { OffersController } from './offers/offers'; import { MessagesController } from './messages/messages'; import { ReportsController } from './reports/reports'; import { NotificationsController } from './notifications/notifications'; import { CurrencyController } from './currency/currency.controller'; import { ReferralsController } from './referrals.controller';
import { VerificationController } from './verification/verification.controller'; import { VerificationService } from './verification/verification.service';
import { FraudController } from './fraud/fraud.controller'; import { FraudService } from './fraud/fraud.service'; import { FraudGraphController } from './fraud/fraud-graph.controller'; import { FraudGraphService } from './fraud/fraud-graph.service';
import { PaymentsController } from './payments/payments.controller'; import { PaymentsService } from './payments/payments.service'; import { PaymentRouterController } from './payments/payment-router.controller'; import { PaymentRouterService } from './payments/payment-router.service';
import { AdminController } from './admin/admin.controller'; import { MessagesGateway } from './messages/messages.gateway';
import { StorageController } from './storage/storage.controller'; import { StorageService } from './storage/storage.service';
import { KycController } from './kyc/kyc.controller'; import { KycService } from './kyc/kyc.service'; import { SanctionsController } from './sanctions/sanctions.controller'; import { SanctionsService } from './sanctions/sanctions.service';
import { AccountSecurityService } from './security/account-security.service'; import { PushController } from './push/push.controller'; import { PushService } from './push/push.service'; import { CommunicationsController } from './communications/communications.controller'; import { CommunicationsService } from './communications/communications.service';
import { SafeguardingController } from './safeguarding/safeguarding.controller'; import { SafeguardingService } from './safeguarding/safeguarding.service'; import { ImpactController } from './impact/impact.controller'; import { PublicController } from './public/public.controller'; import { NetworkController } from './network/network.controller';
@Module({imports:[ThrottlerModule.forRoot([{ttl:60000,limit:60}]),JwtModule.register({})],controllers:[HealthController,AuthController,CasesController,UsersController,SecurityController,CountriesController,OffersController,MessagesController,ReportsController,NotificationsController,CurrencyController,ReferralsController,VerificationController,FraudController,FraudGraphController,PaymentsController,PaymentRouterController,AdminController,StorageController,KycController,SanctionsController,PushController,CommunicationsController,SafeguardingController,ImpactController,PublicController,NetworkController,GlobalController,CountryOperationsController],providers:[PrismaService,AuthService,CasesService,SecurityService,AccountSecurityService,VerificationService,FraudService,FraudGraphService,PaymentsService,PaymentRouterService,MessagesGateway,StorageService,KycService,SanctionsService,PushService,CommunicationsService,SafeguardingService,CountryOperationsService,{provide:APP_GUARD,useClass:ThrottlerGuard},{provide:APP_GUARD,useClass:JwtAuthGuard},{provide:APP_GUARD,useClass:RolesGuard}]}) export class AppModule {}

