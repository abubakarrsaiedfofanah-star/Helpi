import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { IsInt, IsOptional, IsString, MinLength } from 'class-validator';

class CreateCircleDto { @IsString() @MinLength(2) name!: string; @IsOptional() @IsString() purpose?: string; @IsOptional() @IsInt() goalMinor?: number; @IsOptional() @IsString() currency?: string; }
class AppealDto { @IsString() @MinLength(10) reason!: string; }
class CreateOrgDto { @IsString() @MinLength(2) name!: string; @IsString() type!: string; @IsString() countryCode!: string; @IsOptional() @IsString() city?: string; @IsOptional() @IsString() description?: string; }

@Controller('network') @UseGuards(JwtAuthGuard)
export class NetworkController {
 constructor(private readonly p:PrismaService){}
 @Post('circles') async createCircle(@Req() req:any,@Body() dto:CreateCircleDto){return this.p.helpCircle.create({data:{ownerId:req.user.user.id,...dto,members:{create:{userId:req.user.user.id,role:'OWNER'}}},include:{members:true}})}
 @Get('circles') async circles(@Req() req:any){return this.p.helpCircle.findMany({where:{OR:[{ownerId:req.user.user.id},{members:{some:{userId:req.user.user.id,status:'ACTIVE'}}}]},include:{members:{select:{userId:true,role:true,status:true}}},orderBy:{updatedAt:'desc'}})}
 @Post('organizations') async createOrg(@Req() req:any,@Body() dto:CreateOrgDto){const org=await this.p.organization.create({data:{...dto,countryCode:dto.countryCode.toUpperCase(),members:{create:{userId:req.user.user.id,role:'OWNER'}}}});return org}
 @Get('organizations/mine') async mine(@Req() req:any){return this.p.organization.findMany({where:{members:{some:{userId:req.user.user.id,status:'ACTIVE'}}},include:{members:{select:{userId:true,role:true,status:true}}}})}
 @Post('cases/:caseId/appeals') async appeal(@Req() req:any,@Param('caseId') caseId:string,@Body() dto:AppealDto){const c=await this.p.helpCase.findUnique({where:{id:caseId},select:{id:true}});if(!c) throw new Error('Case not found');return this.p.appeal.create({data:{caseId,appellantId:req.user.user.id,reason:dto.reason}})}
 @Get('appeals') async appeals(@Req() req:any){return this.p.appeal.findMany({where:{appellantId:req.user.user.id},orderBy:{createdAt:'desc'}})}
}
