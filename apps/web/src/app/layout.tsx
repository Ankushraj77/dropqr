import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DROPQR Studio | Shop workspace",
  description: "Private customer file receiving and document preparation for service shops.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}