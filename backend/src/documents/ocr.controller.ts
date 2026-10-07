import {Body,Controller,Post,UseGuards} from '@nestjs/common'; import {OcrService} from './ocr.service'; import {AuthGuard} from '../auth/auth.guard';
@Controller('documents') @UseGuards(AuthGuard) export class OcrController{constructor(private readonly o:OcrService){} @Post('ocr') process(@Body()b:{storageKey:string}){return this.o.process(b.storageKey)}}
