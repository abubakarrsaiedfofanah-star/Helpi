import { createCipheriv, createDecipheriv, createHmac, randomBytes } from 'crypto';
function key(){const raw=process.env.MFA_ENCRYPTION_KEY_B64;if(!raw)throw new Error('MFA_ENCRYPTION_KEY_B64 is not configured.');const k=Buffer.from(raw,'base64');if(k.length!==32)throw new Error('MFA_ENCRYPTION_KEY_B64 must decode to 32 bytes.');return k;}
export function seal(value:string){const iv=randomBytes(12);const c=createCipheriv('aes-256-gcm',key(),iv);const data=Buffer.concat([c.update(value,'utf8'),c.final()]);const tag=c.getAuthTag();return [iv,tag,data].map(v=>v.toString('base64url')).join('.');}
export function openSealed(value:string){const [iv,tag,data]=value.split('.').map(v=>Buffer.from(v,'base64url'));const d=createDecipheriv('aes-256-gcm',key(),iv);d.setAuthTag(tag);return Buffer.concat([d.update(data),d.final()]).toString('utf8');}
export function privateFingerprint(value:string){const secret=key();return createHmac('sha256',secret).update(value).digest('hex');}
