import { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'Helpi Admin',
    short_name: 'Helpi Admin',
    description: 'Manage support requests and community safety.',
    start_url: '/',
    display: 'standalone',
    background_color: '#fff8f1',
    theme_color: '#ff7a00',
    icons: [{ src: '/helpi_logo.png', sizes: '512x512', type: 'image/png' }],
  };
}
