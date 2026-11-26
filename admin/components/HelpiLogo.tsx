import Image from 'next/image';

export function HelpiLogo({ className = '' }: { className?: string }) {
  return (
    <Image
      className={className}
      src="/helpi_logo.png"
      alt="Helpi"
      width={64}
      height={64}
    />
  );
}
