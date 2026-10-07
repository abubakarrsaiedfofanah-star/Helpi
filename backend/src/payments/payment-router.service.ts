import {Injectable} from '@nestjs/common'; import {PaymentRouter} from './providers/router';
@Injectable() export class PaymentRouterService{private router=new PaymentRouter(); initiate(country:string,i:any){return this.router.forCountry(country).initiate(i)}}
