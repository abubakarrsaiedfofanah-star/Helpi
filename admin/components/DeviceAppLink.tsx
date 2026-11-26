'use client';

import type { MouseEvent, ReactNode } from 'react';

export function DeviceAppLink({ className, children }: { className: string; children: ReactNode }) {
  const openForThisDevice = (event: MouseEvent<HTMLAnchorElement>) => {
    const isAndroid = /Android/i.test(navigator.userAgent);
    event.preventDefault();
    window.location.assign(isAndroid ? '/downloads/Helpi-Android.apk' : '/community/');
  };

  return <a className={className} href="/get-the-app/" onClick={openForThisDevice}>{children}</a>;
}
