import {Body,Controller,Get,Patch,Param,UseGuards} from '@nestjs/common';
import {PrismaService} from '../prisma.service';
import {JwtAuthGuard} from '../auth/jwt.guard';
import {Roles} from '../roles.decorator';
import {UserRole} from '@prisma/client';

@Controller('admin') @UseGuards(JwtAuthGuard) @Roles(UserRole.ADMIN)
export class AdminController{
 constructor(private readonly p:PrismaService){}
 @Get('dashboard') async dashboard(){
  const [users,cases,verification,fraud,reports,transactions,safeguarding,organizations,helpCircles,appeals]=await Promise.all([
   this.p.user.count(),this.p.helpCase.count(),this.p.verificationRequest.count({where:{status:{in:['PENDING','IN_REVIEW']}}}),this.p.fraudSignal.count({where:{status:'OPEN'}}),this.p.report.count({where:{status:'OPEN'}}),this.p.transaction.count(),this.p.safeguardingCase.count({where:{status:{in:['OPEN','TRIAGED','INVESTIGATING']}}}),this.p.organization.count(),this.p.helpCircle.count({where:{status:'ACTIVE'}}),this.p.appeal.count({where:{status:'OPEN'}})
  ]);return{users,cases,verificationQueue:verification,fraudQueue:fraud,openReports:reports,transactions,openSafeguarding:safeguarding,organizations,helpCircles,appeals};
 }
 @Get('verification-queue') queue(){return this.p.verificationRequest.findMany({where:{status:{in:['PENDING','IN_REVIEW']}},include:{case:true,requester:{select:{id:true,name:true,email:true}}},orderBy:{createdAt:'asc'},take:100})}
 @Get('fraud-queue') fraud(){return this.p.fraudSignal.findMany({where:{status:'OPEN'},include:{case:true},orderBy:{createdAt:'asc'},take:100})}
 @Get('appeals') appeals(){return this.p.appeal.findMany({where:{status:'OPEN'},include:{case:{select:{id:true,title:true,status:true,verificationStatus:true}},appellant:{select:{id:true,name:true,email:true}}},orderBy:{createdAt:'asc'},take:100})}
 @Get('safeguarding') safeguarding(){return this.p.safeguardingCase.findMany({where:{status:{in:['OPEN','TRIAGED','INVESTIGATING']}},include:{report:true},orderBy:{createdAt:'asc'},take:100})}
 @Get('audit') audit(){return this.p.auditLog.findMany({orderBy:{createdAt:'desc'},take:100})}
 @Get('media-review') media(){return this.p.caseEvidence.findMany({where:{moderationStatus:{in:['REVIEW','SCANNING','PENDING']}},include:{case:{select:{id:true,title:true,countryCode:true,status:true,verificationStatus:true}}},orderBy:{createdAt:'asc'},take:100})}
 @Patch('media/:id/review') async review(@Param('id') id:string,@Body() b:{status:'APPROVED'|'REVIEW'|'BLOCKED';reason?:string}){return this.p.caseEvidence.update({where:{id},data:{moderationStatus:b.status,moderationReason:b.reason||null}})}
}
