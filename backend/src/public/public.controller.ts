import { Controller, Get, Param, Query } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
@Controller('public')
export class PublicController {
  constructor(private readonly p: PrismaService) {}
  @Get('cases') async cases(@Query('country') country?: string, @Query('category') category?: string) {
    return this.p.helpCase.findMany({where:{status:'PUBLISHED',verificationStatus:'VERIFIED',...(country?{countryCode:country.toUpperCase()}:{}),...(category?{category:category.toUpperCase() as any}:{})},select:{id:true,title:true,description:true,category:true,goalMinor:true,currency:true,countryCode:true,city:true,verificationStatus:true,createdAt:true,updatedAt:true},orderBy:{updatedAt:'desc'},take:50});
  }
  @Get('countries/:code') async country(@Param('code') code:string){const countryCode=code.toUpperCase();const [cases,organizations,projects]=await Promise.all([this.p.helpCase.count({where:{countryCode,status:'PUBLISHED',verificationStatus:'VERIFIED'}}),this.p.organization.count({where:{countryCode,status:'VERIFIED'}}),this.p.project.count({where:{countryCode,status:{in:['PLANNING','ACTIVE','COMPLETED']}}})]);return{countryCode,cases,organizations,projects};}
  @Get('impact') async impact(@Query('country') country?:string){return this.p.publicImpactSnapshot.findMany({where:country?{countryCode:country.toUpperCase()}:undefined,orderBy:{capturedAt:'desc'},take:100});}
  @Get('organizations') async organizations(@Query('country') country?:string){return this.p.organization.findMany({where:{status:'VERIFIED',...(country?{countryCode:country.toUpperCase()}: {})},select:{id:true,name:true,type:true,countryCode:true,city:true,description:true,website:true},orderBy:{name:'asc'},take:100});}
}
