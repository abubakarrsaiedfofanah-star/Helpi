import './globals.css';
import type { Viewport } from 'next';

export const metadata = {
  title: 'Helpi | Community support',
  description: 'Download the Helpi Android app or use community support online.',
  applicationName: 'Helpi',
  icons: { icon: '/helpi_logo.png', apple: '/pwa-192.png' },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  viewportFit: 'cover',
  themeColor: '#ff7a00',
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body>{children}</body></html>;
}
