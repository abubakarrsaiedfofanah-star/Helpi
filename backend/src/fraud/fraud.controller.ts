import { Body, Controller, Get, Param, Patch, Post, Req, Query } from '@nestjs/common';
import { FraudService } from './fraud.service'; import { Roles } from '../roles.decorator'; import { UserRole } from '@prisma/client';
@Controller('fraud') export class FraudController { constructor(private s:FraudService){}
@Post('cases/:caseId/scan') @Roles(UserRole.VERIFIER,UserRole.ADMIN) scan(@Req() r:any,@Param('caseId') id:string){return this.s.scanCase(id,r.user.sub)}
@Get('signals') @Roles(UserRole.VERIFIER,UserRole.ADMIN) list(@Query('status') status?:string){return this.s.list(status)}
@Patch('signals/:id') @Roles(UserRole.VERIFIER,UserRole.ADMIN) resolve(@Req() r:any,@Param('id') id:string,@Body() b:{status:'REVIEWED'|'DISMISSED'|'CONFIRMED',note?:string}){return this.s.resolve(id,r.user.sub,b.status,b.note)} }
