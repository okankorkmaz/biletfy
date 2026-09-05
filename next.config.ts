import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  poweredByHeader: false,
  // Docker imajı için: node_modules'ü kopyalamadan çalışan tek klasörlük çıktı.
  output: "standalone",
};

export default nextConfig;
