'use client';

import { usePathname } from 'next/navigation';
import styles from '../app/(public)/public-site.module.css';

export function PublicSiteNav() {
  const pathname = usePathname();
  const home = pathname === '/';

  return (
    <nav className={styles.nav} aria-label="Main navigation">
      <a href={home ? '#home' : '/#home'} aria-current={home ? 'page' : undefined}>Home</a>
      <a href={home ? '#about' : '/about/'}>About us</a>
      <a href={home ? '#what-we-do' : '/what-we-do/'}>What we do</a>
      <a href="/community/">Community app</a>
    </nav>
  );
}
