import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
@Injectable()
export class StorageService {
 private readonly bucket=process.env.STORAGE_BUCKET; private readonly client=new S3Client({region:process.env.AWS_REGION||'us-east-1'});
 private ensure(){if(!this.bucket||!process.env.AWS_ACCESS_KEY_ID||!process.env.AWS_SECRET_ACCESS_KEY) throw new Error('Private object storage is not configured');}
 async createUploadUrl(i:{ownerId:string;mimeType:string;sizeBytes:number;folder:string}){this.ensure(); const allowed=new Set(['image/jpeg','image/png','image/webp','application/pdf','video/mp4','video/webm','video/quicktime','audio/mpeg','audio/mp4']); if(!allowed.has(i.mimeType)) throw new Error('File type is not allowed'); const max=i.mimeType.startsWith('video/')?Number(process.env.MAX_VIDEO_UPLOAD_BYTES||104857600):Number(process.env.MAX_UPLOAD_BYTES||10485760); if(i.sizeBytes<=0||i.sizeBytes>max) throw new Error('File size is not allowed'); const safeFolder=['private','case-videos','case-evidence'].includes(i.folder)?i.folder:'private'; const key=`${safeFolder}/${i.ownerId}/${randomUUID()}`; const c=new PutObjectCommand({Bucket:this.bucket,Key:key,ContentType:i.mimeType,ServerSideEncryption:'aws:kms',SSEKMSKeyId:process.env.AWS_KMS_KEY_ID}); return {key,uploadUrl:await getSignedUrl(this.client,c,{expiresIn:300})};}
 async createDownloadUrl(key:string){this.ensure(); const c=new GetObjectCommand({Bucket:this.bucket,Key:key}); return {downloadUrl:await getSignedUrl(this.client,c,{expiresIn:300})};}
}
