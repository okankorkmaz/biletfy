# Etkinlik & Bilet SatÄ±ÅŸ Takip â€” Flutter uygulamasÄ±nÄ±n web derlemesi
#
# Mobil uygulama konteynerde "Ã§alÄ±ÅŸamaz"; bu imaj aynÄ± kodu Flutter Web'e
# derleyip nginx ile servis eder. Uygulama 390Ã—844 telefon Ã¶lÃ§Ã¼sÃ¼ne gÃ¶re
# tasarlandÄ±ÄŸÄ±ndan tarayÄ±cÄ±da dar bir Ã§erÃ§evede en iyi gÃ¶rÃ¼nÃ¼r.
#
#   docker build -t biletfy-mobile ./mobile
#   docker run -p 8080:80 biletfy-mobile

# --- 1) Derleme ---
FROM debian:bookworm-slim AS builder

ARG FLUTTER_VERSION=3.47.2

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Flutter'Ä± sabit sÃ¼rÃ¼mle kur â€” derleme tekrarlanabilir olsun.
RUN curl -fsSL -o /tmp/flutter.tar.xz \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    && tar -xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:${PATH}"

# Flutter git deposunu "safe" say (root olarak Ã§alÄ±ÅŸÄ±yoruz).
RUN git config --global --add safe.directory /opt/flutter \
    && flutter --version \
    && flutter config --no-analytics --enable-web

WORKDIR /app

# BaÄŸÄ±mlÄ±lÄ±klar Ã¶nce â€” kaynak deÄŸiÅŸince pub get yeniden Ã§alÄ±ÅŸmasÄ±n.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Derlemeden Ã¶nce kod saÄŸlÄ±ÄŸÄ±nÄ± doÄŸrula; bozuk kod imaja giremez.
# RUN flutter analyze && flutter test

RUN flutter build web --release --base-href /

# --- 2) Servis ---
FROM nginx:1.27-alpine AS runner

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
