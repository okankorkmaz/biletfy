# Faz 1 — Ortak katalog ve tarih koruması

## Kapsam ve uygulama durumu

Bu değişiklik Flutter, Next.js ve ilk migration dosyasını değiştirmez. Yeni migration
yalnızca izole PostgreSQL üzerinde doğrulanır; üretim Supabase'e uygulanmaz.
Canlı sağlayıcı, rapor, bildirim, adapter ve istemci bağlantısı içermez.

`20260905191100_shared_catalog_foundation.sql` tek transaction'dır. Kilit bekleme
sınırı 5 saniye, migration süre sınırı 60 saniyedir. Yoğun bir veritabanında güvenli
biçimde hata verebilir; süreyi körlemesine artırmak yerine kilitler incelenmelidir.
Çalışma ortamında Supabase CLI olmadığı için ek paket kurulmadan migration dosyası
hazırlanmıştır; migration geçmişi hiçbir uzak ortamda oluşturulmamıştır.

## Kesin şema sözleşmesi

19 yeni tablo:

- Katalog: `catalog_entities`, `artists`, `catalog_events`, `event_participants`,
  `shows`, `venues`, `venue_spaces`.
- Sağlayıcı: `providers`, `provider_listings`.
- Kullanıcı: `user_follows`, `user_favorites`.
- Operasyon: `ingestion_jobs`, `collection_attempts`, `collection_results`.
- Geçmiş: `ticket_observations`, `ticket_observation_tiers`.
- Geçiş: `legacy_tracking_map`, `legacy_event_map`, `legacy_snapshot_map`.

`catalog_entities` ortak takip kimliğidir. Tipli alt tablolar birleşik foreign key
ile artist/event/show türünü doğrular. `catalog_events.event_type` ve
`artists.artist_type` açık metindir: yeni konser/tiyatro/film sınıfı DDL gerektirmez.
Üç yapısal kimlik türü sabittir; yeni bir yapısal tür eklemek migration gerektirir.
Etkinlik türlerinin kontrollü sözlüğü ileride eklenebilir.

Sanatçı-etkinlik ilişkisi çoktan çoğadır. Etkinlik birden fazla gösteriye sahiptir.
Gösterinin mekânı ve salonu nullable'dır; biliniyorsa salonun doğru mekâna ait
olması birleşik FK ile doğrulanır. Saatler `timestamptz`, iş saat dilimi ayrı
alandır. Saat dilimi adlarının doğrulanması sonraki ingestion katmanına aittir.

İlan kimliği `(provider_id, external_namespace, external_id)` ile benzersizdir.
Sağlayıcılar tablo kayıtlarıdır, enum değildir. Migration sağlayıcı kaydı eklemez.
İlan kimliği/gösteri ilişkisi sonradan değiştirilemez. Gösteri başka etkinliğe
taşınamaz. Hatalı eşlemeler için sonraki aşamada açık, denetlenebilir düzeltme
akışı gerekir; geçmişi başka varlığa sessizce bağlamak kabul edilmez.

Takip/favori `(user_id, entity_id)` ile benzersizdir. Kullanıcı kimliği ortak
katalog, ilan veya gözlem sahipliğinde bulunmaz. Güncelleme işlemi yoktur;
ilişki eklenir veya kaldırılır. Takip bırakmak katalog verisini silmez.

## Toplama ve gözlem kuralları

İşin `idempotency_key` değeri benzersizdir. Worker henüz uygulanmamıştır;
`scheduled_at`, `lease_until`, durum ve deneme numarası gelecekteki worker için
temeldir. İş/kiralama alanları backend tarafından güncellenebilir.

Deneme running durumundan yalnızca bir kez sonuçlandırılır. Terminal deneme
güncellenemez veya silinemez. Sonuç satırı terminal denemenin sağlayıcı ve durumuna
birleşik FK ile bağlıdır. Kısmi deneme başarılı ve başarısız ilan sonuçları
taşıyabilir; başarısız deneme başarılı sonuç taşıyamaz.

Gözlem yalnızca `succeeded` sonucuna bağlanabilir. Her sonuç en fazla bir gözlem
taşır; aynı sonucu farklı parser/scope ile tekrar yazmak da engellenir. Fiyat
kategorileri aynı gözlemin `ticket_observation_tiers` satırlarıdır. Bir sonraki
gerçek toplama yeni deneme ve sonuçla yeni gözlem oluşturur.

Gözlem ve kategoriler UPDATE/DELETE/TRUNCATE kabul etmez. Backend rolü yalnızca
SELECT/INSERT alır; tetikleyiciler tablo sahibinin olağan DML işlemlerini de
engeller. Veritabanı yöneticisi tetikleyicileri kaldırabilir: DDL yetkisine karşı
mutlak değişmezlik iddiası yoktur. Düzeltme/supersession akışı bu aşamada yoktur.
Gözlem ve kategoriler backend tarafından aynı transaction'da yazılmalıdır.

Metriklerin varsayılanı NULL'dır. Sıfır gerçek bir ölçümdür; yalnızca başarılı ve
doğrulanmış sonuçtan gelebilir. `occupancy` yüzde 0–100 aralığındadır. Kapasite
sıfır olabilir ancak sıfıra bölerek doluluk hesaplanmaz. Migration hiçbir satış,
doluluk veya gelir hesaplamaz. Sağlayıcı envanterlerini birleştiren fonksiyon yoktur.
Fiyatlar/gelir ondalıklıdır. Para birimi bilinmiyorsa NULL kalır; böyle bir fiyat
gösterimi veya toplamı gelecekteki okuma katmanında açıkça eksik sayılmalıdır.

`measurement_scope` envanter kapsamını, `measurement_origin` bildirilen/türetilen/
tahmin edilen/bilinmeyen ayrımını taşır. Karma kaynaklı metriklerde
`quality_metadata.metrics` altında her metriğin kaynak ve eksiklik nedeni
belirtilmelidir. `parser_version` ve `normalizer_version` zorunludur.
`observed_at`, `source_timestamp`, `recorded_at` farklı anlamları korur.

Ham sağlayıcı verisi yalnızca backend'in erişebildiği
`collection_results.raw_payload` içindedir. Büyük payload için özel nesne deposu
sonraki aşamadır. Gözlemden sonuca FK ile ham veriye ulaşılır.

Tazelik `observed_at` ve sağlayıcının `freshness_seconds` eşiğinden sorgu anında
hesaplanmalıdır. `freshness_metadata` tarihsel bağlamdır, canlı stale bayrağı
değildir. Başarısız deneme eski başarılı verinin zamanını yenilemez. Güncel okuma
API'si, metrik bazlı tazelik ve doğrulanmış kaynak seçimi bu aşamada uygulanmaz.

## Yetkiler ve RLS

Yeni 19 tablonun tamamında RLS açıktır. Supabase'in olası varsayılan geniş
yetkileri açık REVOKE ile kaldırılır.

- Authenticated: yayımlanmış katalog/sağlayıcı/ortak ilan SELECT.
- Authenticated: yalnızca kendi takip/favorisi SELECT, INSERT, DELETE.
- Anon: yeni tablolarda yetki yok.
- Service role: katalog/eşleme/iş alanlarında SELECT, INSERT, UPDATE;
  gözlem, kategori ve sonuçlarda SELECT, INSERT; takip/favoride DELETE de mevcut.
- Operasyon, ham veri, eşleme ve gözlemler istemciye tamamen kapalıdır.
  Sonraki aşamada güvenli bir okuma sözleşmesi eklenmelidir.
- Restricted ilanlar istemciye görünmez. Özel organizatör hesaplarına yetki
  modeli bu fazda yoktur; bu kaynaklar henüz bağlanmamalıdır.

15 politika: yayımlanmış katalog için 9 SELECT politikası, takip/favori için
ayrı ayrı sahiplik SELECT/INSERT/DELETE politikaları. Kullanıcıdan gelen
user_metadata veya gönderilen user_id ayrıcalık kaynağı değildir.

`biletify_private` şemasında 4 SECURITY INVOKER tetikleyici fonksiyonu vardır.
PUBLIC/anon/authenticated EXECUTE yetkileri kaldırılmıştır. SECURITY DEFINER
fonksiyonu veya RLS'yi atlayan görünüm eklenmemiştir.

## Eski silme zincirinin korunması

Mevcut zincir: `auth.users → tracked_entities → events → ticket_snapshots`.
Üç mevcut foreign key CASCADE olarak **yerinde kalır**. Eklenen BEFORE DELETE
tetikleyicileri silme işlemini hata ile atomik olarak geri alır; TRUNCATE da
korunur. Snapshot UPDATE işlemi de engellenir. Hiçbir eski satır değiştirilmez.

Sonuç: eski takip kaydı bulunan kullanıcının Auth hesabını silmek de engellenir.
Bu, tarih kaybına karşı geçici ve bilinçli davranıştır. Eski takipten çıkma
`is_active=false` ile yapılır. Yalnızca yeni ilişkileri olan hesabın silinmesi
yeni takip/favorileri siler ama ortak veriye dokunmaz. Hesap silme/anonymization
geçişi ayrıca tasarlanmadan eski korumalar kaldırılmamalıdır.

## Tekrarlanabilir backfill

`scripts/phase1_legacy_backfill.sql` otomatik migration değildir; ayrıca incelenip
backend yetkisiyle çalıştırılır. İlk çalıştırmada sadece pending_review eşlemeleri
oluşur. Kaynak isimlerine bakılarak artist/event/show/venue yaratılmaz veya birleştirilmez.

İncelemeci gerçek kaynak/dış kimlik, namespace, gösteri tarihi/mekânı ve yayın
hakkını doğrulamalıdır. İlgili katalog/ilan kayıtlarını oluşturup tracking/event
eşlemesine hedef FK'leri, `review_note`, `reviewed_at`, `approved` yazmalıdır.
Onaylanmış event eşlemesi sonradan değiştirilemez.

Sonraki çalıştırma:

1. İncelenmiş aktif takipleri bir kez aktarır; pasifleri de işlenmiş sayar.
2. Onaylı event eşlemesindeki en fazla 1000 bekleyen snapshot'ı aktarır.
3. Özgün snapshot satırını ve `captured_at` değerini korur. Scope/origin/currency
   tahmin edilmez. Serbest metin availability ham sonuç metaverisinde korunur;
   normalize edilmiş availability NULL kalır.
4. `legacy_import` işi ve sonucu oluşturur. Başarı burada **aktarım başarısıdır**;
   geçmişte sağlayıcının başarılı yanıt verdiğine kanıt değildir. Metaveri bunu
   açıkça belirtir; gerçek kaynak gözlemleriyle kalite bakımından eşit sayılmamalıdır.
5. Geçersiz fiyat vb. kayıtları blocked yapar; orijinali düzeltmez. Teknik/yetki
   hataları sessizce yutulmaz, transaction başarısız olur.
6. Advisory transaction lock paralel betik çalıştırmalarını sıralar. Eşleme
   anahtarları ve aktarım işaretleri tekrar yazımı engeller. Silinen yeni takip
   sonraki çalıştırmada diriltilmez.

1000 sınırı snapshot aktarımı içindir; ilk eşleme envanteri toplu INSERT yapar.
Çok büyük eski veride envanter de anahtar aralıklarına bölünmeden üretimde
çalıştırılmamalıdır. Aynı anda devam eden legacy yazımlar için kontrollü delta
aktarımı gerekir. Bu fazda veri taşıma üretimde yapılmaz.

## Yerel doğrulama

Windows PowerShell: `& .\supabase\tests\run-phase1.ps1`

Runner sabit digest'li PostgreSQL 17 Alpine imajını kullanır. Hazır imaj yoksa
otomatik indirme yapmaz. Yeni paket kurulmaz. Konteyner:

- Her çalıştırmada benzersiz ad ve test etiketi alır.
- `--network none` ile çalışır; host portu açmaz.
- Veriyi tmpfs'te tutar; repo yalnızca read-only mount edilir.
- İş bitince etiketi doğrulanarak durdurulur ve `--rm` ile kaldırılır.

Testte Supabase'in auth.users/auth.uid()/rolleri minimal bir yerel shim ile
oluşturulur. Gerçek GoTrue, PostgREST, Supabase CLI migration runner veya üretim
şema farklılıkları sınanmış sayılmaz. Test bootstrap dosyası gerçek Supabase'de
çalıştırılmamalıdır. Test SQL'i yalnızca bu boş geçici konteyner içindir.

Testler RLS/GRANT, iki kullanıcı ortak takibi, takip ve kullanıcı silme, eski
cascade engeli, NULL, başarısız sonuç, tekrar yazım, yeni gözlem, immutable
kimlik/geçmiş, onaylı/onaysız backfill ve orijinal satır mutabakatını kapsar.
Flutter/Next.js kaynaklarına dokunulmadığı git diff ile kontrol edilir; bu fazda
istemci build/testleri çalıştırılmaz.

5 Eylül 2026 doğrulaması: 45 SQL assertion geçti, `PHASE1_ALL_TESTS_PASSED`
işareti alındı, runner çıkış kodu 0 ve geçici konteyner temizliği başarılı.
İlk denemede test temizliğinin Windows tırnaklaması, genişletilmiş negatif testte
ise duplicate constraint'e önce takılan fixture düzeltildi; son çalıştırma
bütün değişiklikleri içerir. Git kontrolünde mevcut uygulama dosyaları ve ilk
migration değişmemiştir. Üretim veya canlı sağlayıcı testi yapılmamıştır.

## Geri dönüş ve sonraki aşama

Başarısız migration transaction'ı tamamen geri döner. Başarılı migration sonrası
varsayılan geri dönüş yeni veri yolunu kullanmamaktır; yeni tarih silinmez.
İlk migration dosyası değiştirilmediğinden eski şema kaynakları korunur.

Otomatik down/drop dosyası kasıtlı olarak yoktur. Üretimde populated tabloyu
kaldırmak veya eski cascade korumalarını açmak veri kaybı yaratır. İlerideki geri
alma migration'ı yalnızca boş yeni tablolar, doğrulanmış yedek ve eski tarih için
alternatif koruma bulunduğunda ayrıca hazırlanmalıdır. Bu fazda backend dışındaki
hiçbir uygulama yeni tabloya bağımlı değildir.

Önerilen sonraki aşama: Supabase'e özgü yerel entegrasyon doğrulaması ve ortak
nullable/tazelik destekli okuma sözleşmesi. Ardından sahte adapter fixture'larıyla
worker akışı; canlı sağlayıcı ancak ayrı onayla. Flutter'ın zorunlu sayı alanları
ve Vendor enum'u doğrudan gerçek bilinmeyen veriye bağlanamaz. Tasarım/screen
refactor gerektirmeyen dar model uyarlaması ayrıca planlanmalıdır.

Başvurulan resmi kaynaklar:
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://www.postgresql.org/docs/current/ddl-constraints.html
