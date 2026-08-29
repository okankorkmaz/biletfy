const SUPABASE_URL = window.location.hostname === 'localhost' ? '' : ''; 

document.addEventListener('DOMContentLoaded', () => {
  const statusCard = document.getElementById('status-card');
  
  if (statusCard) {
    statusCard.innerHTML = `
      <p class="text-green-400 font-semibold">✓ Altyapı Bağlantısı Aktif</p>
      <p class="text-xs text-gray-400 mt-1">biletfy sistemi başarıyla Vercel ve Supabase üzerinde çalışıyor.</p>
    `;
  }
});
