import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import * as fs from 'fs';
import * as path from 'path';

const defaults = {
  languages: ['en'], currencies: [], paymentMethods: [],
  kycRequirements: { identityRequired: true, enhancedThresholdMinor: null, acceptedDocumentTypes: [] },
  kybRequirements: { enabled: true, requiredForOrganizations: true, documents: [] },
  safeguardingRules: { childSafetyReview: true, exactAddressesPublic: false, escalationRequired: true, restrictedCommunications: [] },
  emergencyResources: [], documentTypes: [], dataRetention: { identityDays: 2555, caseDays: 2555, financialDays: 2555, deletionRequestWorkflow: true },
  helpMethods: ['MONEY','GOODS','SKILLS','TIME','TRANSPORT','SERVICES'],
  verificationRules: { identity: true, need: true, institution: true, paymentDestination: true, humanReview: true },
  communicationRules: { translation: true, voice: true, video: true, childContactRequiresSafeguards: true }
};

@Injectable()
export class CountryOperationsService {
  constructor(private readonly prisma: PrismaService) {}
  private registry(): any[] { return JSON.parse(fs.readFileSync(path.join(process.cwd(),'data','countries.json'),'utf8')); }
  private base(code: string) {
    const c = this.registry().find(x => x.code === code.toUpperCase());
    if (!c) throw new NotFoundException('Country not found.');
    return {...defaults, languages:['en'], currencies:c.currency?[c.currency]:[], countryCode:c.code, countryName:c.name, continent:c.continent};
  }
  async get(code:string): Promise<any> {
    const countryCode=code.toUpperCase();
    const row=await this.prisma.countryConfiguration.findUnique({where:{countryCode}});
    if(row) return {...this.base(countryCode),...row};
    return {...this.base(countryCode), configured:false};
  }
  async all() {
    const rows=await this.prisma.countryConfiguration.findMany({orderBy:{countryCode:'asc'}});
    const map=new Map(rows.map(r=>[r.countryCode,r]));
    return this.registry().map(c=>({...this.base(c.code),...(map.get(c.code)||{}),configured:map.has(c.code)}));
  }
  async upsert(code:string, body:any, userId?:string) {
    const base=this.base(code); const countryCode=base.countryCode;
    const data:any={countryCode,enabled:body.enabled ?? true,defaultLanguage:body.defaultLanguage ?? base.languages[0],languages:body.languages ?? base.languages,currencies:body.currencies ?? base.currencies,paymentMethods:body.paymentMethods ?? [],kycRequirements:body.kycRequirements ?? defaults.kycRequirements,kybRequirements:body.kybRequirements ?? defaults.kybRequirements,safeguardingRules:body.safeguardingRules ?? defaults.safeguardingRules,emergencyResources:body.emergencyResources ?? [],documentTypes:body.documentTypes ?? [],dataRetention:body.dataRetention ?? defaults.dataRetention,helpMethods:body.helpMethods ?? defaults.helpMethods,verificationRules:body.verificationRules ?? defaults.verificationRules,communicationRules:body.communicationRules ?? defaults.communicationRules,updatedById:userId ?? null};
    const result=await this.prisma.countryConfiguration.upsert({where:{countryCode},create:data,update:data});
    if(userId) await this.prisma.auditLog.create({data:{userId,action:'COUNTRY_CONFIGURATION_UPDATED',metadata:{countryCode}}});
    return {...base,...result,configured:true};
  }
}
