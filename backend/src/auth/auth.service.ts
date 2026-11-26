import { ConflictException, Injectable, UnauthorizedException, BadRequestException, ServiceUnavailableException } from '@nestjs/common';
import { JwtService, JwtSignOptions } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { createHmac, randomBytes } from 'crypto';
import { PrismaService } from '../prisma.service';
import { hashToken, randomToken } from '../common'; import { seal, openSealed } from '../crypto';
import { LoginDto, RegisterDto } from './dto';
import { AccountSecurityService } from '../security/account-security.service';

function base32Decode(input:string){const alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';let bits='';for(const c of input.replace(/=+$/,'')){const v=alphabet.indexOf(c.toUpperCase());if(v<0)throw new Error('Invalid secret');bits+=v.toString(2).padStart(5,'0');}const out:number[]=[];for(let i=0;i+8<=bits.length;i+=8)out.push(parseInt(bits.slice(i,i+8),2));return Buffer.from(out);}
function totp(secret:string, counter:number){const key=base32Decode(secret);const b=Buffer.alloc(8);b.writeBigUInt64BE(BigInt(counter));const h=createHmac('sha1',key).update(b).digest();const o=h[h.length-1]&15;const n=(h.readUInt32BE(o)&0x7fffffff)%1000000;return String(n).padStart(6,'0');}
function verifyTotp(secret:string,code:string){const c=Math.floor(Date.now()/1000/30);return [-1,0,1].some(i=>totp(secret,c+i)===code);}
function randomBase32(bytes=20){const alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';let out='';const b=randomBytes(bytes);let buffer=0,bits=0;for(const x of b){buffer=(buffer<<8)|x;bits+=8;while(bits>=5){bits-=5;out+=alphabet[(buffer>>bits)&31];}}if(bits>0)out+=alphabet[(buffer<<(5-bits))&31];return out;}

@Injectable() export class AuthService{
 constructor(private prisma:PrismaService,private jwt:JwtService,private accountSecurity:AccountSecurityService){}
 async register(dto:RegisterDto,meta:any){
  const exposeDevToken=process.env.NODE_ENV!=='production'&&process.env.EXPOSE_DEV_TOKENS==='true';
  const resendApiKey=process.env.RESEND_API_KEY?.trim();
  const webhookUrl=process.env.EMAIL_WEBHOOK_URL?.trim();
  const webhookSecret=process.env.EMAIL_WEBHOOK_SECRET;
  const verificationBase=process.env.EMAIL_VERIFICATION_BASE_URL?.trim();
  if(!webhookUrl&&!resendApiKey&&!exposeDevToken)throw new ServiceUnavailableException('Email verification is not configured. Please try again later.');
  if((webhookUrl&&!webhookSecret)||((webhookUrl||resendApiKey)&&!verificationBase))throw new ServiceUnavailableException('Email verification is not configured correctly. Please contact support.');
  let webhook:URL|undefined;
  let verificationUrl:URL|undefined;
  if(webhookUrl||((resendApiKey)&&verificationBase)){
   try{if(webhookUrl)webhook=new URL(webhookUrl);verificationUrl=new URL(verificationBase!);if((webhook&&!['https:','http:'].includes(webhook.protocol))||!['https:','http:'].includes(verificationUrl.protocol))throw new Error('Unsupported URL scheme');if(process.env.NODE_ENV==='production'&&((webhook&&webhook.protocol!=='https:')||verificationUrl.protocol!=='https:'))throw new Error('HTTPS is required');}
   catch{throw new ServiceUnavailableException('Email verification requires valid HTTPS webhook and app URLs.');}
  }
  const email=dto.email.trim().toLowerCase();
  if(await this.prisma.user.findUnique({where:{email}}))throw new ConflictException('Account already exists.');
  const passwordHash=await argon2.hash(dto.password,{type:argon2.argon2id,memoryCost:19456,timeCost:2,parallelism:1});
  const user=await this.prisma.user.create({data:{email,passwordHash,name:dto.name.trim(),countryCode:dto.countryCode.toUpperCase(),supportGroup:dto.supportGroup,status:'PENDING',publicIdentityMode:dto.anonymousPublic?'ANONYMOUS':(dto.publicAlias?'ALIAS':'REAL_NAME'),publicAlias:dto.publicAlias?.trim()||null}});
  const raw=randomToken();
  const expiresAt=new Date(Date.now()+30*60*1000);
  await this.prisma.emailVerificationToken.create({data:{userId:user.id,tokenHash:hashToken(raw),expiresAt}});
  await this.audit(user.id,'ACCOUNT_CREATED',meta);
  if(verificationUrl&&(webhook||resendApiKey)){
   verificationUrl.searchParams.set('token',raw);
   const subject='Verify your Helpi account';
   const link=verificationUrl.toString();
   const text=`Hello ${user.name},\n\nVerify your Helpi account within 30 minutes by opening this link:\n${link}\n\nIf you did not create this account, ignore this email.`;
   try{
    const response=webhook&&webhookSecret
     ? await fetch(webhook,{method:'POST',headers:{'content-type':'application/json','authorization':`Bearer ${webhookSecret}`,'x-helpi-event':'email.verification'},body:JSON.stringify({event:'email.verification',to:user.email,name:user.name,subject,text,verificationUrl:link,verificationToken:raw,expiresAt:expiresAt.toISOString()}),signal:AbortSignal.timeout(10000)})
     : await fetch('https://api.resend.com/emails',{method:'POST',headers:{'content-type':'application/json','authorization':`Bearer ${resendApiKey}`},body:JSON.stringify({from:process.env.EMAIL_FROM?.trim()||'Helpi <onboarding@resend.dev>',to:[user.email],subject,text,html:`<p>Hello ${user.name.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!))},</p><p>Verify your Helpi account within 30 minutes:</p><p><a href="${link}">Verify my account</a></p><p>If you did not create this account, ignore this email.</p>`}),signal:AbortSignal.timeout(10000)});
    if(!response.ok)throw new Error(`Email webhook returned ${response.status}`);
   }catch{
    await this.prisma.$transaction(async tx=>{await tx.emailVerificationToken.deleteMany({where:{userId:user.id}});await tx.user.delete({where:{id:user.id}});});
    throw new ServiceUnavailableException('We could not send the verification email. Please try again shortly.');
   }
  }
  return {verificationRequired:true,verificationTokenForDevelopment:exposeDevToken?raw:undefined};
 }
 async verifyEmail(raw:string){const now=new Date();const t=await this.prisma.emailVerificationToken.findUnique({where:{tokenHash:hashToken(raw)}});if(!t||t.usedAt||t.expiresAt<now)throw new BadRequestException('Verification link is invalid or expired.');const result=await this.prisma.$transaction(async tx=>{const claimed=await tx.emailVerificationToken.updateMany({where:{id:t.id,usedAt:null,expiresAt:{gt:now}},data:{usedAt:now}});if(claimed.count!==1)throw new BadRequestException('Verification link is invalid or expired.');return tx.user.update({where:{id:t.userId},data:{status:'ACTIVE',emailVerifiedAt:now}});});await this.audit(result.id,'EMAIL_VERIFIED',{});return {ok:true};}
 async login(dto:LoginDto,meta:any){const user=await this.prisma.user.findUnique({where:{email:dto.email.trim().toLowerCase()}});if(!user)throw new UnauthorizedException('Invalid email or password.');if(user.lockedUntil&&user.lockedUntil>new Date())throw new UnauthorizedException('Account temporarily locked. Try again later.');if(user.status!=='ACTIVE')throw new UnauthorizedException('Please verify your email before signing in.');const ok=await argon2.verify(user.passwordHash,dto.password);if(!ok){const count=user.failedLoginCount+1;await this.prisma.user.update({where:{id:user.id},data:{failedLoginCount:count,lockedUntil:count>=5?new Date(Date.now()+15*60*1000):null}});await this.audit(user.id,'LOGIN_FAILED',meta);throw new UnauthorizedException('Invalid email or password.');}if(user.mfaEnabled){if(!dto.mfaCode||!user.mfaSecretEncrypted||!verifyTotp(openSealed(user.mfaSecretEncrypted),dto.mfaCode))throw new UnauthorizedException('MFA code required or invalid.');}await this.prisma.user.update({where:{id:user.id},data:{failedLoginCount:0,lockedUntil:null,lastLoginAt:new Date()}});await this.accountSecurity.inspectLogin(user.id,meta);await this.audit(user.id,'LOGIN_SUCCESS',meta);return this.issue(user,meta);}
 async refresh(raw:string,meta:any){const now=new Date();const s=await this.prisma.refreshSession.findUnique({where:{tokenHash:hashToken(raw)},include:{user:true}});if(!s||s.revokedAt||s.expiresAt<=now||s.user.status!=='ACTIVE')throw new UnauthorizedException('Refresh session expired.');const claimed=await this.prisma.refreshSession.updateMany({where:{id:s.id,revokedAt:null,expiresAt:{gt:now}},data:{revokedAt:now}});if(claimed.count!==1)throw new UnauthorizedException('Refresh session expired.');return this.issue(s.user,meta);}
 async revoke(raw:string){await this.prisma.refreshSession.updateMany({where:{tokenHash:hashToken(raw),revokedAt:null},data:{revokedAt:new Date()}});return {ok:true};}
 async revokeAll(userId:string){await this.prisma.refreshSession.updateMany({where:{userId,revokedAt:null},data:{revokedAt:new Date()}});return {ok:true};}
 async setupMfa(userId:string){const user=await this.prisma.user.findUnique({where:{id:userId},select:{email:true,mfaEnabled:true}});if(!user)throw new UnauthorizedException('Account unavailable.');if(user.mfaEnabled)throw new BadRequestException('Two-factor authentication is already enabled.');const secret=randomBase32();await this.prisma.user.update({where:{id:userId},data:{mfaSecretEncrypted:seal(secret)}});const label=`Helpi:${user.email}`;const otpauthUrl=`otpauth://totp/${encodeURIComponent(label)}?secret=${secret}&issuer=Helpi&algorithm=SHA1&digits=6&period=30`;return {secret,issuer:'Helpi',account:user.email,otpauthUrl};}
 async enableMfa(userId:string,code:string){const u=await this.prisma.user.findUnique({where:{id:userId}});if(!u?.mfaSecretEncrypted||!verifyTotp(openSealed(u.mfaSecretEncrypted),code))throw new BadRequestException('Invalid MFA code.');await this.prisma.user.update({where:{id:userId},data:{mfaEnabled:true}});await this.audit(userId,'MFA_ENABLED',{});return {ok:true};}
 async disableMfa(userId:string,code:string){const u=await this.prisma.user.findUnique({where:{id:userId}});if(!u?.mfaSecretEncrypted||!verifyTotp(openSealed(u.mfaSecretEncrypted),code))throw new BadRequestException('Invalid MFA code.');await this.prisma.user.update({where:{id:userId},data:{mfaEnabled:false,mfaSecretEncrypted:null}});await this.audit(userId,'MFA_DISABLED',{});return {ok:true};}
 private async issue(user:any,meta:any){const access=await this.jwt.signAsync({sub:user.id,role:user.role,jti:randomBytes(12).toString('hex')},{secret:process.env.JWT_ACCESS_SECRET,expiresIn:(process.env.ACCESS_TOKEN_TTL??'10m') as JwtSignOptions['expiresIn']});const refresh=randomToken();await this.prisma.refreshSession.create({data:{userId:user.id,tokenHash:hashToken(refresh),userAgent:meta.userAgent,ipAddress:meta.ip,expiresAt:new Date(Date.now()+30*24*60*60*1000)}});return {accessToken:access,refreshToken:refresh,user:{id:user.id,email:user.email,name:user.name,countryCode:user.countryCode,supportGroup:user.supportGroup,role:user.role,mfaEnabled:user.mfaEnabled,publicIdentityMode:user.publicIdentityMode,publicAlias:user.publicAlias}};}
 private audit(userId:string,action:string,meta:any){return this.prisma.auditLog.create({data:{userId,action,ipAddress:meta.ip,userAgent:meta.userAgent}});}
}
