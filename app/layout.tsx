import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Biletify | Etkinlik Takip Merkezi",
  description: "Etkinlik biletlerini, doluluk oranlarını ve günlük değişimleri takip edin.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="tr">
      <body>{children}</body>
    </html>
  );
}
