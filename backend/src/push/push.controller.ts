import {Body,Controller,Post,UseGuards} from '@nestjs/common'; import {PushService} from './push.service'; import {AuthGuard} from '../auth/auth.guard';
@Controller('push') @UseGuards(AuthGuard) export class PushController{constructor(private readonly p:PushService){} @Post('send') send(@Body()b:any){return this.p.send(b)}}
