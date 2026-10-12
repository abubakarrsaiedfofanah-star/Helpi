import { BadRequestException, Body, Controller, Get, Headers, Post, Req } from '@nestjs/common';
import { createHmac, timingSafeEqual } from 'crypto';
import { PaymentsService } from './payments.service';
import { AccountSecurityService } from '../security/account-security.service';

@Controller('payments')
export class PaymentsController {
  constructor(private s: PaymentsService, private account: AccountSecurityService) {}

  @Post('intents')
  create(@Req() r:any, @Body() b:{caseId:string;amountMinor:number;currency:string;purpose?:string;idempotencyKey?:string}) {
    return this.s.createIntent(r.user.sub,b);
  }

  @Get('mine')
  mine(@Req() r:any) { return this.s.listMine(r.user.sub); }

  @Get('payout-destination')
  payoutDestination(@Req() r:any) { return this.s.payoutDestination(r.user.sub); }

  @Post('payout-destination')
  savePayoutDestination(@Req() r:any,@Body() b:{countryCode:string;method:string;phone:string}) { return this.account.createPayoutDestination(r.user.sub,{...b,destination:b.phone}); }

  @Post('webhooks/provider')
  webhook(@Headers('x-payment-signature') signature:string,@Body() b:any) {
    const secret=process.env.PAYMENT_WEBHOOK_SECRET;
    if(!secret) throw new BadRequestException('Payment provider is not configured.');
    if(!signature) throw new BadRequestException('Missing payment signature.');
    const raw=JSON.stringify(b);
    const expected=createHmac('sha256',secret).update(raw).digest('hex');
    let valid=false;
    try {
      const a=Buffer.from(signature,'hex'),e=Buffer.from(expected,'hex');
      valid=a.length===e.length && timingSafeEqual(a,e);
    } catch { valid=false; }
    if(!valid) throw new BadRequestException('Invalid payment event.');
    return this.s.webhook(b);
  }
}
