import { ConnectedSocket, MessageBody, SubscribeMessage, WebSocketGateway, WebSocketServer } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma.service';
@WebSocketGateway({namespace:'/realtime',cors:{origin:process.env.CORS_ORIGINS?.split(',').map(x=>x.trim())||[]}})
export class MessagesGateway {
 @WebSocketServer() server!:Server;
 constructor(private jwt:JwtService,private prisma:PrismaService){}
 async handleConnection(socket:Socket){ try { const token=(socket.handshake.auth?.token||socket.handshake.headers.authorization?.replace('Bearer ','')) as string; const p:any=await this.jwt.verifyAsync(token,{secret:process.env.JWT_ACCESS_SECRET}); const u=await this.prisma.user.findUnique({where:{id:p.sub},select:{id:true,status:true}}); if(!u||u.status!=='ACTIVE') return socket.disconnect(true); (socket as any).userId=u.id; } catch { socket.disconnect(true); } }
 @SubscribeMessage('thread:join') async join(@ConnectedSocket() socket:Socket,@MessageBody() body:{threadId:string}){ const uid=(socket as any).userId; const thread=await this.prisma.messageThread.findFirst({where:{id:body.threadId,participants:{some:{id:uid}}}}); if(!thread) return {ok:false,error:'Not a participant'}; await socket.join(`thread:${body.threadId}`); return {ok:true}; }
 @SubscribeMessage('message:send') async send(@ConnectedSocket() socket:Socket,@MessageBody() body:{threadId:string,body:string}){ const uid=(socket as any).userId; const text=(body.body||'').trim(); if(!text||text.length>5000)return {ok:false,error:'Invalid message'}; const thread=await this.prisma.messageThread.findFirst({where:{id:body.threadId,participants:{some:{id:uid}}}}); if(!thread)return {ok:false,error:'Not a participant'}; const m=await this.prisma.message.create({data:{threadId:body.threadId,senderId:uid,body:text}}); this.server.to(`thread:${body.threadId}`).emit('message:new',m); return {ok:true,message:m}; }
}
