"use client";

import { useMemo, useState } from "react";

type Event = { id: number; artist: string; title: string; city: string; venue: string; date: string; occupancy: number; delta: number; sold: number; capacity: number; source: string; status: "Satışta" | "Tükeniyor" };

const initialEvents: Event[] = [
  { id: 1, artist: "Doğu Demirkol", title: "Doğu Demirkol Gösterisi", city: "İstanbul", venue: "Harbiye Cemil Topuzlu", date: "12 Eyl 2026 · 21:00", occupancy: 84, delta: 6.2, sold: 3780, capacity: 4500, source: "Biletix", status: "Tükeniyor" },
  { id: 2, artist: "Doğu Demirkol", title: "Doğu Demirkol Gösterisi", city: "Ankara", venue: "ATO Congresium", date: "19 Eyl 2026 · 20:30", occupancy: 67, delta: 3.8, sold: 2010, capacity: 3000, source: "Bubilet", status: "Satışta" },
  { id: 3, artist: "Doğu Demirkol", title: "Doğu Demirkol Gösterisi", city: "İzmir", venue: "İzmir Kültürpark", date: "26 Eyl 2026 · 21:00", occupancy: 52, delta: 2.1, sold: 1300, capacity: 2500, source: "Biletinial", status: "Satışta" },
];

function Icon({ name }: { name: string }) {
  const icons: Record<string, string> = { grid: "▦", event: "◫", watch: "◎", report: "↗", bell: "◌", search: "⌕", plus: "+", trend: "↗" };
  return <span aria-hidden="true">{icons[name]}</span>;
}

export function Dashboard() {
  const [events, setEvents] = useState(initialEvents);
  const [query, setQuery] = useState("");
  const [showAdd, setShowAdd] = useState(false);
  const [active, setActive] = useState("Genel Bakış");
  const filtered = useMemo(() => events.filter(e => `${e.artist} ${e.city} ${e.venue}`.toLocaleLowerCase("tr").includes(query.toLocaleLowerCase("tr"))), [events, query]);
  const totals = useMemo(() => ({ sold: events.reduce((a,e)=>a+e.sold,0), capacity: events.reduce((a,e)=>a+e.capacity,0) }), [events]);

  function addTracking(formData: FormData) {
    const artist = String(formData.get("artist") || "Yeni Sanatçı");
    const city = String(formData.get("city") || "Türkiye");
    setEvents(prev => [...prev, { id: Date.now(), artist, title: `${artist} Etkinlikleri`, city, venue: "Mekân taranıyor", date: "Tarih aranıyor", occupancy: 0, delta: 0, sold: 0, capacity: 0, source: "Tarama kuyruğu", status: "Satışta" }]);
    setShowAdd(false);
  }

  return (
    <div className="shell">
      <aside>
        <div className="brand"><span className="brandmark">b</span><span>biletify<small>Etkinlik zekâsı</small></span></div>
        <nav>{[["grid","Genel Bakış"],["event","Etkinlikler"],["watch","Takip Listem"],["report","Raporlar"]].map(([icon,label]) => <button key={label} className={active===label?"active":""} onClick={()=>setActive(label)}><Icon name={icon}/>{label}</button>)}</nav>
        <div className="sidefoot"><span className="avatar">OK</span><span><b>Okan Korkmaz</b><small>Demo hesabı</small></span><button aria-label="Ayarlar">•••</button></div>
      </aside>

      <main>
        <header><div><button className="mobile-logo">b</button><h1>{active}</h1><p>Etkinlik performansını tek ekrandan izle.</p></div><div className="header-actions"><label className="search"><Icon name="search"/><input value={query} onChange={e=>setQuery(e.target.value)} placeholder="Sanatçı, şehir veya mekân ara" /></label><button className="bell" aria-label="Bildirimler"><Icon name="bell"/><i/></button><button className="primary" onClick={()=>setShowAdd(true)}><Icon name="plus"/> Yeni takip</button></div></header>

        <section className="notice"><span>●</span><div><b>Demo modu aktif</b><p>Arayüz örnek verilerle çalışıyor. Supabase bağlandığında gerçek hesap ve tarama verilerine otomatik geçilecek.</p></div></section>

        <section className="stats">
          <article><div><span>Takip edilen etkinlik</span><b>{events.length}</b></div><em className="purple">◫</em><small><strong>+1</strong> bu hafta</small></article>
          <article><div><span>Toplam satılan bilet</span><b>{totals.sold.toLocaleString("tr-TR")}</b></div><em className="green">↗</em><small><strong>+4,7%</strong> son 24 saat</small></article>
          <article><div><span>Ortalama doluluk</span><b>%{Math.round((totals.sold/totals.capacity)*100)||0}</b></div><em className="orange">◔</em><small><strong>+3,2 puan</strong> düne göre</small></article>
          <article><div><span>Aktif kaynak</span><b>3 / 3</b></div><em className="blue">◎</em><small><strong>●</strong> Sistem sağlıklı</small></article>
        </section>

        <section className="content-grid">
          <article className="panel events"><div className="panel-title"><div><h2>Yaklaşan etkinlikler</h2><p>Satış hareketine göre önceliklendirilmiş</p></div><button>Tümünü gör →</button></div>
            <div className="event-list">{filtered.map(event => <div className="event-row" key={event.id}><div className="poster">DD</div><div className="event-info"><b>{event.title}</b><span>{event.city} · {event.venue}</span><small>{event.date}</small></div><div className="source">{event.source}<small>{event.status}</small></div><div className="bar-info"><div><span>Doluluk</span><b>%{event.occupancy}</b></div><div className="bar"><i style={{width:`${event.occupancy}%`}}/></div><small><strong>↑ %{event.delta}</strong> bugün</small></div></div>)}</div>
            {filtered.length===0 && <div className="no-results">Aramana uygun etkinlik bulunamadı.</div>}
          </article>
          <article className="panel pulse"><div className="panel-title"><div><h2>Satış nabzı</h2><p>Son 7 günlük toplam değişim</p></div><span className="live">● CANLI</span></div><div className="chart"><div className="chart-value"><small>Bugün</small><b>+312</b><span>bilet</span></div><svg viewBox="0 0 500 170" role="img" aria-label="Yükselen satış grafiği"><defs><linearGradient id="fill" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stopColor="#6c5ce7" stopOpacity=".28"/><stop offset="1" stopColor="#6c5ce7" stopOpacity="0"/></linearGradient></defs><path className="area" d="M0 140 C60 132 70 105 120 112 S190 124 230 92 S300 82 335 58 S405 78 450 28 L500 18 L500 170 L0 170Z"/><path className="line" d="M0 140 C60 132 70 105 120 112 S190 124 230 92 S300 82 335 58 S405 78 450 28 L500 18"/></svg><div className="days"><span>Pzt</span><span>Sal</span><span>Çar</span><span>Per</span><span>Cum</span><span>Cmt</span><span>Paz</span></div></div><div className="insight"><span>✦</span><p><b>Satış ivmesi yükseliyor</b>İstanbul etkinliği son 24 saatte en hızlı büyüyen etkinlik.</p></div></article>
        </section>

        {showAdd && <div className="modal-backdrop" onMouseDown={()=>setShowAdd(false)}><form className="modal" action={addTracking} onMouseDown={e=>e.stopPropagation()}><button type="button" className="close" onClick={()=>setShowAdd(false)}>×</button><span className="modal-icon">◎</span><h2>Yeni takip oluştur</h2><p>Bir sanatçı, ünlü veya etkinlik adı ekle. Kaynakları tarayıp bulunan etkinlikleri listeye alacağız.</p><label>Sanatçı / etkinlik adı<input name="artist" required placeholder="Örn. Doğu Demirkol" autoFocus /></label><label>Şehir<input name="city" placeholder="Tüm Türkiye" /></label><div className="modal-actions"><button type="button" onClick={()=>setShowAdd(false)}>Vazgeç</button><button className="primary" type="submit">Takibi başlat</button></div></form></div>}
      </main>
    </div>
  );
}
