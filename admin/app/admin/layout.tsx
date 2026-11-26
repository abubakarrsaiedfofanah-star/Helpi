import type { Metadata } from 'next';
import { PwaRegistration } from '../../components/PwaRegistration';

export const metadata: Metadata = {
  title: 'Helpi Admin | Secure portal',
  description: 'Secure administrator access for Helpi community operations.',
  manifest: '/admin/manifest.webmanifest',
  robots: { index: false, follow: false },
};

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return <><PwaRegistration />{children}</>;
}
