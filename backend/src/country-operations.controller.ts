import { Body, Controller, Get, Param, Patch, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './auth/jwt.guard';
import { Roles } from './roles.decorator';
import { UserRole } from '@prisma/client';
import { CountryOperationsService } from './country-operations.service';

@Controller('country-operations')
export class CountryOperationsController {
  constructor(private readonly service: CountryOperationsService) {}
  @Get() @UseGuards(JwtAuthGuard) @Roles(UserRole.ADMIN)
  all(){ return this.service.all(); }
  @Get('public/:code')
  publicGet(@Param('code') code:string){ return this.service.get(code).then(x=>({countryCode:x.countryCode,countryName:x.countryName,continent:x.continent,enabled:x.enabled,defaultLanguage:x.defaultLanguage,languages:x.languages,currencies:x.currencies,paymentMethods:x.paymentMethods,helpMethods:x.helpMethods,emergencyResources:x.emergencyResources,communicationRules:x.communicationRules})); }
  @Get(':code') @UseGuards(JwtAuthGuard) @Roles(UserRole.ADMIN)
  get(@Param('code') code:string){ return this.service.get(code); }
  @Patch(':code')
  @UseGuards(JwtAuthGuard) @Roles(UserRole.ADMIN)
  update(@Param('code') code:string,@Body() body:any,@Req() req:any){ return this.service.upsert(code,body,req.user?.user?.id); }
}
