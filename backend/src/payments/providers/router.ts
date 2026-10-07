import {PaymentProviderAdapter} from './provider'; import {MpesaProvider} from './mpesa.provider';
export class PaymentRouter{private providers:PaymentProviderAdapter[]=[new MpesaProvider()]; forCountry(country:string){const p=this.providers.find(x=>x.countryCodes.includes(country));if(!p)throw new Error(`No configured payment adapter for ${country}`);return p}}
