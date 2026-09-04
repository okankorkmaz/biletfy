"use client";
export default function ErrorPage({ reset }: { reset: () => void }) {
  return <main className="center"><section className="empty"><h1>Bir şeyler ters gitti</h1><p>Veriler alınırken beklenmeyen bir hata oluştu.</p><button onClick={reset}>Tekrar dene</button></section></main>;
}
