import {Body,Controller,Post,UseGuards} from '@nestjs/common'; import {CommunicationsService} from './communications.service'; import {AuthGuard} from '../auth/auth.guard';
@Controller('communications') @UseGuards(AuthGuard) export class CommunicationsController{constructor(private readonly c:CommunicationsService){} @Post('room') room(@Body()b:any){return this.c.createRoom(b)}}
