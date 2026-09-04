import Link from "next/link";
export default function NotFound() {
  return <main className="center"><section className="empty"><b>404</b><h1>Sayfa bulunamadı</h1><Link href="/">Panele dön</Link></section></main>;
}
