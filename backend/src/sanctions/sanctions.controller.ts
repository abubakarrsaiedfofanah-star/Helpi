import {Body,Controller,Post,UseGuards} from '@nestjs/common'; import {SanctionsService} from './sanctions.service'; import {AuthGuard} from '../auth/auth.guard';
@Controller('sanctions') @UseGuards(AuthGuard) export class SanctionsController{constructor(private readonly s:SanctionsService){} @Post('screen') screen(@Body()b:any){return this.s.screen(b)}}
