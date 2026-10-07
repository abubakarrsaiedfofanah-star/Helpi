import { Body, Controller, Post, Req } from '@nestjs/common'; import { Request } from 'express'; import { IsEnum, IsOptional, IsString, MaxLength, MinLength } from 'class-validator'; import { PrismaService } from '../prisma.service';
export enum ReportType { FRAUD='FRAUD',HARASSMENT='HARASSMENT',SCAM='SCAM',SAFEGUARDING='SAFEGUARDING',OTHER='OTHER' }
export class ReportDto{@IsEnum(ReportType) type!:ReportType;@IsString() @MinLength(10) @MaxLength(3000) description!:string;@IsOptional() @IsString() caseId?:string;}
@Controller('reports') export class ReportsController{constructor(private p:PrismaService){} @Post() create(@Req() r:Request,@Body() d:ReportDto){return this.p.report.create({data:{...d,reporterId:(r as any).user.sub}});}}
