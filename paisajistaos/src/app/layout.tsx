import type { Metadata } from 'next';
import './globals.css';
import ClientApp from './ClientApp';

export const metadata: Metadata = {
  title: 'PaisajistaOS - Centro Operativo de Paisajismo',
  description: 'Gestiona proyectos, cuadrillas, materiales y evidencia visual para paisajismo profesional en Colombia.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es-CO">
      <body>
        <ClientApp>{children}</ClientApp>
      </body>
    </html>
  );
}
