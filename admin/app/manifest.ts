import type { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
  return {
    id: '/',
    name: 'Helpi Admin',
    short_name: 'Helpi Admin',
    description: 'Manage Helpi community accounts, support requests, organizations, and safety.',
    start_url: '/',
    scope: '/',
    display: 'standalone',
    background_color: '#fff8f1',
    theme_color: '#ff7a00',
    icons: [
      { src: '/pwa-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
      { src: '/pwa-512.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
      { src: '/pwa-maskable-192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
      { src: '/pwa-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
    ],
  };
}
