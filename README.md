# Biletify

Türkiye'deki etkinliklerin bilet satışını, doluluk oranını ve günlük değişimini takip eden web paneli.

## Çalıştırma

Node.js 22+ ile:

```bash
npm install
npm run dev
```

Supabase olmadan demo verileriyle çalışır. Gerçek veri modu için `.env.example` dosyasını `.env.local` olarak kopyalayın ve Supabase proje URL'si ile publishable key'i ekleyin. Ardından `supabase/migrations` altındaki migration'ı projeye uygulayın.

## Kontroller

```bash
npm run typecheck
npm run build
```
