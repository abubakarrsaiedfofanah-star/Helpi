import { Controller,Get } from '@nestjs/common'; import * as fs from 'fs'; import * as path from 'path';
@Controller('countries') export class CountriesController{ @Get() all(){return JSON.parse(fs.readFileSync(path.join(process.cwd(),'data','countries.json'),'utf8'));} }
