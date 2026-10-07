import {Injectable} from '@nestjs/common';
export interface KycProvider{verify(input:any):Promise<any>}
@Injectable() export class KycService{private provider:KycProvider=new ConfiguredKycProvider(); verify(i:any){return this.provider.verify(i)}}
class ConfiguredKycProvider implements KycProvider{async verify(i:any){const base=process.env.KYC_PROVIDER_URL;if(!base)return{provider:'manual-review',status:'REVIEW',reference:`manual-${Date.now()}`,reason:'KYC provider is not configured; manual review required'};const r=await fetch(`${base}/verify`,{method:'POST',headers:{'content-type':'application/json',authorization:`Bearer ${process.env.KYC_PROVIDER_API_KEY||''}`},body:JSON.stringify(i)});if(!r.ok)throw new Error(`KYC provider returned ${r.status}`);return r.json()}}
