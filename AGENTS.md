# Repository Guidelines

## Proje Yapısı ve Modül Organizasyonu

`app/`, Next.js web panelini ve `app/ui/` altındaki ortak arayüz bileşenlerini içerir. Flutter uygulaması `mobile/` içindedir; kaynaklar `mobile/lib/` altında `screens`, `widgets`, `models`, `data`, `theme` ve `core` olarak ayrılır. Mobil testler `mobile/test/`, görseller `mobile/assets/` altındadır. PostgreSQL migration, backfill ve doğrulama dosyaları `supabase/` içinde tutulur. Tasarım kaynakları `design/` altındadır. Web ve mobil uygulama kodlarını birbirine taşımayın; ortak iş kurallarını mümkün olduğunda backend katmanında tutun.

## Derleme, Test ve Geliştirme Komutları

Kök dizinde Node.js 22+ kullanın:

- `npm run dev`: Next.js geliştirme sunucusunu başlatır.
- `npm run typecheck`: TypeScript tip kontrolünü çalıştırır.
- `npm run build`: production web derlemesini doğrular.
- `docker compose up --build`: web uygulamasını `localhost:3001` üzerinde çalıştırır.

Mobil uygulama için `cd mobile` sonrasında:

- `flutter run`: bağlı cihaz veya emülatörde çalıştırır.
- `dart format lib test`: Dart kaynaklarını biçimlendirir.
- `flutter analyze`: lint ve statik analiz yapar.
- `flutter test`: tüm widget/unit testlerini çalıştırır.
- `flutter build apk --debug`: Android debug APK üretir.

## Kod Stili ve Adlandırma

TypeScript’te iki boşluklu girinti ve mevcut bileşen düzenini; Dart’ta `dart format` çıktısını kullanın. Sınıf ve widget adları `PascalCase`, değişken ve fonksiyonlar `camelCase`, Dart dosyaları `snake_case.dart` olmalıdır. Flutter’da feature-first yapı ile repository soyutlamasını koruyun. Provider veya scraping mantığını UI içine yerleştirmeyin. Yeni bağımlılık eklemeden önce gerekliliğini açıklayın.

## Test Kuralları

Flutter testleri `flutter_test` kullanır ve `*_test.dart` biçiminde adlandırılır. Davranış değişikliğinde kullanıcı akışını doğrulayan küçük bir widget testi ekleyin. Migration’ları yalnızca izole yerel Supabase ortamında, temiz kurulum ve RLS senaryolarıyla doğrulayın. Bilinmeyen iş metriklerini sıfıra çevirmeyin.

## Commit ve Pull Request Kuralları

Geçmişteki biçimi izleyin: `feat(mobile): ...`, `fix(mobile): ...`, `chore(docker): ...`, `docs: ...`. Her commit tek bir amacı kapsamalıdır. PR açıklaması problemi, davranış değişikliğini ve çalıştırılan kontrolleri belirtmelidir. UI değişikliklerinde ekran görüntüsü; şema değişikliklerinde migration, RLS etkisi ve geri dönüş yaklaşımı ekleyin. Secret, service-role key veya production kimlik bilgisi commit etmeyin.
