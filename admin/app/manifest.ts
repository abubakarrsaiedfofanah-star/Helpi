import { MetadataRoute } from 'next';
export default function manifest(): MetadataRoute.Manifest {
  return {name:'Helpi — Real Help, Global Impact',short_name:'Helpi',description:'A security-first humanitarian assistance network.',start_url:'/',display:'standalone',background_color:'#fff8f1',theme_color:'#ff7a00',icons:[{src:'/helpi_logo.png',sizes:'512x512',type:'image/png'}]};
}
