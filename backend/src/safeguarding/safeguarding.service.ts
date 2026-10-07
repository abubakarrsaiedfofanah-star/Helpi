import {Injectable} from '@nestjs/common'; import {PrismaService} from '../prisma.service';
@Injectable() export class SafeguardingService{constructor(private readonly prisma:PrismaService){} async open(i:any){return this.prisma.report.create({data:{reporterId:i.reporterId,caseId:i.caseId,type:'SAFEGUARDING',description:i.description}})}}
