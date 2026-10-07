import { Body, Controller, Get, Param, Patch, Post, Query, Req } from '@nestjs/common'; import { Request } from 'express'; import { CasesService } from './cases.service'; import { CreateCaseDto } from './dto';
@Controller('cases') export class CasesController{constructor(private s:CasesService){}
 @Get() list(@Query('q') q?:string,@Query('category') category?:string,@Query('country') country?:string){return this.s.list(q,category,country)}
 @Get('mine') mine(@Req() r:Request){return this.s.mine((r as any).user.sub)}
 @Get(':id') get(@Param('id') id:string){return this.s.get(id)}
 @Post() create(@Req() r:Request,@Body() d:CreateCaseDto){return this.s.create((r as any).user.sub,d)}
 @Patch(':id/status') status(@Req() r:Request,@Param('id') id:string,@Body() body:{status:'PAUSED'|'DRAFT'}){return this.s.updateStatus((r as any).user.sub,id,body.status)}
}
