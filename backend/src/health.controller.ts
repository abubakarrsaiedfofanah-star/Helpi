import { Controller, Get } from '@nestjs/common';
@Controller('health')
export class HealthController { @Get() health() { return { status:'ok', service:'helpi-api', version:'2.0.0', timestamp:new Date().toISOString() }; } }
