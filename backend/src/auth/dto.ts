import { IsEmail, IsOptional, IsString, IsBoolean, MaxLength, MinLength } from 'class-validator';
export class RegisterDto { @IsEmail() email!:string; @IsString() @MinLength(12) @MaxLength(128) password!:string; @IsString() @MinLength(2) @MaxLength(80) name!:string; @IsString() @MinLength(2) @MaxLength(2) countryCode!:string; @IsOptional() @IsBoolean() anonymousPublic?:boolean; @IsOptional() @IsString() @MaxLength(40) publicAlias?:string; }
export class LoginDto { @IsEmail() email!:string; @IsString() @MinLength(1) @MaxLength(128) password!:string; @IsOptional() @IsString() @MaxLength(8) mfaCode?:string; }
export class RefreshDto { @IsString() @MinLength(20) refreshToken!:string; }
export class VerifyEmailDto { @IsString() @MinLength(20) token!:string; }
export class ResetRequestDto { @IsEmail() email!:string; }
export class ResetPasswordDto { @IsString() @MinLength(20) token!:string; @IsString() @MinLength(12) @MaxLength(128) newPassword!:string; }
export class MfaCodeDto { @IsString() @MinLength(6) @MaxLength(8) code!:string; }
