import {Body,Controller,Post,Req,UseGuards} from '@nestjs/common'; import {KycService} from './kyc.service'; import {AuthGuard} from '../auth/auth.guard';
@Controller('kyc') @UseGuards(AuthGuard) export class KycController{constructor(private readonly k:KycService){} @Post('verify') verify(@Req()r:any,@Body()b:any){return this.k.verify({...b,userId:r.user.sub})}}
