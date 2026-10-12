import { Body, Controller, Get, Headers, Ip, Post, Req } from '@nestjs/common'; import { Throttle } from '@nestjs/throttler'; import { Request } from 'express'; import { AuthService } from './auth.service'; import { RegisterDto,LoginDto,RefreshDto,VerifyEmailDto,MfaCodeDto } from './dto';
@Controller('auth') export class AuthController{constructor(private auth:AuthService){}
 @Throttle({default:{limit:5,ttl:60000}}) @Post('register') register(@Body() d:RegisterDto,@Ip() ip:string,@Headers('user-agent') ua='unknown'){return this.auth.register(d,{ip,userAgent:ua});}
 @Throttle({default:{limit:8,ttl:60000}}) @Post('login') login(@Body() d:LoginDto,@Ip() ip:string,@Headers('user-agent') ua='unknown'){return this.auth.login(d,{ip,userAgent:ua});}
 @Post('refresh') refresh(@Body() d:RefreshDto,@Ip() ip:string,@Headers('user-agent') ua='unknown'){return this.auth.refresh(d.refreshToken,{ip,userAgent:ua});}
 @Post('logout') logout(@Body() d:RefreshDto){return this.auth.revoke(d.refreshToken);}
 @Post('verify-email') verify(@Body() d:VerifyEmailDto){return this.auth.verifyEmail(d.token);}
 @Get('me') me(@Req() r:Request){const current=(r as any).user;return current.user??current;}
 @Post('mfa/setup') setup(@Req() r:Request){return this.auth.setupMfa((r as any).user.sub);}
 @Post('mfa/enable') enable(@Req() r:Request,@Body() d:MfaCodeDto){return this.auth.enableMfa((r as any).user.sub,d.code);}
 @Post('mfa/disable') disable(@Req() r:Request,@Body() d:MfaCodeDto){return this.auth.disableMfa((r as any).user.sub,d.code);}
}
