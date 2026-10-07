import {Body,Controller,Post,UseGuards} from '@nestjs/common'; import {AuthGuard} from '../auth/auth.guard'; import {PaymentRouterService} from './payment-router.service';
@Controller('payments') @UseGuards(AuthGuard) export class PaymentRouterController{constructor(private readonly p:PaymentRouterService){} @Post('country-init') init(@Body()b:any){return this.p.initiate(b.countryCode,b)}}
