<template>
  <footer id="contact" class="footer">
    <div class="footer-content">
      <div class="footer-main">
        <div class="footer-brand">
          <div class="footer-logo">
            <div class="footer-logo-symbol">
              <svg width="1847" height="2133" viewBox="0 0 1847 2133" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
                <path d="M1829.85 1462.98L678.199 2127.48C654.042 2141.42 623.746 2121.67 625.803 2093.33L677.898 1375.48C679.971 1346.91 649.224 1327.17 625.081 1341.57L53.0338 1682.85C24.6865 1699.76 -9.52093 1670.02 2.45834 1638.88L624.522 21.7628C636.655 -9.77734 681.886 -6.17938 690.534 27.0136L1044.03 1383.89C1048.22 1399.97 1062.81 1411.2 1079.1 1410.89L1810.64 1397.01C1846.74 1396.33 1860.93 1445.05 1829.85 1462.98Z" fill="url(#paint0_linear_footer)"/>
                <defs>
                  <linearGradient id="paint0_linear_footer" x1="174.934" y1="908.779" x2="1957.28" y2="1360.64" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#40FBDC"/>
                    <stop offset="1" stop-color="#722695"/>
                  </linearGradient>
                </defs>
              </svg>
            </div>
            <span class="logo-text">Almerson</span>
          </div>
          <p class="footer-tagline">Votre parc informatique, géré par des experts. Concentrez-vous sur votre métier.</p>
          <div class="footer-social">
            <a href="https://www.linkedin.com/company/almerson/" target="_blank" rel="noopener" class="social-link" aria-label="LinkedIn">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M16 8a6 6 0 016 6v7h-4v-7a2 2 0 00-2-2 2 2 0 00-2 2v7h-4v-7a6 6 0 016-6zM2 9h4v12H2z"/><circle cx="4" cy="4" r="2" fill="currentColor"/></svg>
            </a>
            <a href="#" class="social-link" aria-label="GitHub">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 00-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0020 4.77 5.07 5.07 0 0019.91 1S18.73.65 16 2.48a13.38 13.38 0 00-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 005 4.77a5.44 5.44 0 00-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 009 18.13V22"/></svg>
            </a>
          </div>
        </div>

        <div class="footer-links">
          <div class="footer-col">
            <h4>Services</h4>
            <a href="#features">Infogérance</a>
            <a href="#features">Cybersécurité</a>
            <a href="#features">Réseau</a>
            <a href="#features">Sauvegarde</a>
          </div>
          <div class="footer-col">
            <h4>Ressources</h4>
            <a href="#">Blog technique</a>
            <a href="#">Cas clients</a>
            <a href="#">FAQ</a>
            <a href="#">Status</a>
          </div>
          <div class="footer-col">
            <h4>Entreprise</h4>
            <a href="#">À propos</a>
            <a href="#">Nos valeurs</a>
            <a href="#contact">Contact</a>
          </div>
          <div class="footer-col">
            <h4>Légal</h4>
            <a href="#">Confidentialité</a>
            <a href="#">CGV</a>
            <a href="#">Sécurité</a>
            <a href="#">SLA</a>
          </div>
        </div>
      </div>

      <div class="footer-bottom">
        <p>© {{ year }} Almerson. Tous droits réservés.</p>
        <div class="footer-meta">
          <span>Infogérance & cybersécurité — Caen, Normandie</span>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
const year = new Date().getFullYear()
</script>

<style scoped>
.footer { border-top: 1px solid rgba(255,255,255,0.08); padding: 80px 40px 40px; background: #000; }
.footer-content { max-width: 1400px; margin: 0 auto; }
.footer-main { display: grid; grid-template-columns: 2fr 3fr; gap: 80px; margin-bottom: 60px; }
.footer-brand { max-width: 350px; }

.footer-logo { display: flex; align-items: center; gap: 12px; margin-bottom: 16px; }
.footer-logo-symbol { width: 36px; height: 36px; animation: logoSmallFloat 4s ease-in-out infinite; }
.footer-logo-symbol svg { width: 100%; height: 100%; filter: drop-shadow(0 0 8px rgba(64,251,220,0.4)); }
@keyframes logoSmallFloat { 0%,100% { transform: translateY(0) rotate(0deg); } 50% { transform: translateY(-4px) rotate(2deg); } }

.logo-text { font-family: 'Montserrat', sans-serif; font-weight: 700; font-size: 18px; letter-spacing: -0.5px; color: #fff; }
.footer-tagline { color: rgba(255,255,255,0.5); font-size: 15px; line-height: 1.6; margin-bottom: 24px; }
.footer-social { display: flex; gap: 12px; }

.social-link { width: 40px; height: 40px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: rgba(255,255,255,0.6); transition: all 0.3s; }
.social-link:hover { background: rgba(64,251,220,0.2); border-color: rgba(64,251,220,0.4); color: #40FBDC; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(64,251,220,0.3); }

.footer-links { display: grid; grid-template-columns: repeat(4, 1fr); gap: 40px; }
.footer-col h4 { font-size: 14px; font-weight: 700; margin-bottom: 16px; color: rgba(255,255,255,0.9); text-transform: uppercase; letter-spacing: 0.5px; }
.footer-col a { display: block; color: rgba(255,255,255,0.5); font-size: 14px; margin-bottom: 12px; transition: all 0.2s; position: relative; padding-left: 0; text-decoration: none; }
.footer-col a:hover { color: #40FBDC; padding-left: 12px; }

.footer-bottom { display: flex; justify-content: space-between; align-items: center; padding-top: 40px; border-top: 1px solid rgba(255,255,255,0.08); }
.footer-bottom p, .footer-meta span { color: rgba(255,255,255,0.4); font-size: 14px; }

@media (max-width: 1024px) { .footer-main { grid-template-columns: 1fr; gap: 60px; } .footer-brand { max-width: 100%; } .footer-links { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { .footer { padding: 60px 24px 40px; } .footer-links { grid-template-columns: 1fr; gap: 32px; } .footer-bottom { flex-direction: column; gap: 16px; text-align: center; } }
</style>