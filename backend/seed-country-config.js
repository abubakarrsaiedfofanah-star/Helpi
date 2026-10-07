const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');
const prisma = new PrismaClient();
const defaults = {
  languages:['en'], paymentMethods:[], kycRequirements:{identityRequired:true,acceptedDocumentTypes:[]}, kybRequirements:{enabled:true,requiredForOrganizations:true,documents:[]},
  safeguardingRules:{childSafetyReview:true,exactAddressesPublic:false,escalationRequired:true}, emergencyResources:[], documentTypes:[],
  dataRetention:{identityDays:2555,caseDays:2555,financialDays:2555,deletionRequestWorkflow:true}, helpMethods:['MONEY','GOODS','SKILLS','TIME','TRANSPORT','SERVICES'],
  verificationRules:{identity:true,need:true,institution:true,paymentDestination:true,humanReview:true}, communicationRules:{translation:true,voice:true,video:true,childContactRequiresSafeguards:true}
};
async function main(){const countries=JSON.parse(fs.readFileSync(path.join(__dirname,'data/countries.json'),'utf8')); for(const c of countries){await prisma.countryConfiguration.upsert({where:{countryCode:c.code},create:{countryCode:c.code,defaultLanguage:'en',languages:defaults.languages,currencies:[c.currency],paymentMethods:defaults.paymentMethods,kycRequirements:defaults.kycRequirements,kybRequirements:defaults.kybRequirements,safeguardingRules:defaults.safeguardingRules,emergencyResources:[],documentTypes:[],dataRetention:defaults.dataRetention,helpMethods:defaults.helpMethods,verificationRules:defaults.verificationRules,communicationRules:defaults.communicationRules},update:{currencies:[c.currency]}});} console.log(`Seeded ${countries.length} country configurations.`)}main().finally(()=>prisma.$disconnect());
