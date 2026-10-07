import { createHash, randomBytes } from 'crypto';
export const hashToken=(v:string)=>createHash('sha256').update(v).digest('hex');
export const randomToken=()=>randomBytes(48).toString('base64url');
export const redactIp=(ip:string|undefined)=>ip?.replace(/(\d+\.\d+\.)(\d+\.)(\d+)/,'$1***.***') ?? undefined;
