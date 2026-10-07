import { Body, Controller, Get, Post, Req } from '@nestjs/common';
import { Request } from 'express';
import { SecurityService } from './security.service';
import { AccountSecurityService } from './account-security.service';

@Controller('security')
export class SecurityController {
  constructor(private security: SecurityService, private account: AccountSecurityService) {}
  @Get('events') events(@Req() r: Request) { return this.security.events((r as any).user.sub); }
  @Post('sessions/revoke-all') revokeAll(@Req() r: Request) { return this.account.revokeAll((r as any).user.sub); }
  @Post('payout-destinations') payout(@Req() r: Request, @Body() b: {countryCode:string;method:string;destination:string}) {
    return this.account.createPayoutDestination((r as any).user.sub, b);
  }
}
