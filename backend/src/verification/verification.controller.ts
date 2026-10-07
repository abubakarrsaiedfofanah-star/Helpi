import { Body, Controller, Get, Param, Patch, Post, Query, Req } from '@nestjs/common';
import { VerificationService } from './verification.service';
import { Roles } from '../roles.decorator';
import { UserRole } from '@prisma/client';
@Controller('verification')
export class VerificationController {
  constructor(private service: VerificationService) {}
  @Post('cases/:caseId/request') request(@Req() req:any,@Param('caseId') caseId:string,@Body() body:{reason?:string}) { return this.service.queue(caseId, req.user.sub, body?.reason); }
  @Get('queue') @Roles(UserRole.VERIFIER, UserRole.ADMIN) queue(@Query('status') status?:string) { return this.service.list(status); }
  @Patch('requests/:id') @Roles(UserRole.VERIFIER, UserRole.ADMIN) review(@Req() req:any,@Param('id') id:string,@Body() body:{status:'VERIFIED'|'REJECTED'|'NEEDS_MORE_EVIDENCE',reason?:string}) { return this.service.review(id, req.user.sub, body.status, body.reason); }
}
