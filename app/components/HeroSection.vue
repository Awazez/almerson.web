<template>
  <section class="hero">
    <div class="floating-orb orb-1" aria-hidden="true"></div>
    <div class="floating-orb orb-2" aria-hidden="true"></div>
    <div class="floating-orb orb-3" aria-hidden="true"></div>
    <div class="floating-orb orb-4" aria-hidden="true"></div>
    <div class="floating-orb orb-5" aria-hidden="true"></div>
    <div class="floating-orb orb-6" aria-hidden="true"></div>

    <div class="hero-inner">
      <div class="hero-content">
        <div class="hero-badge">
          <span class="pulse-dot"></span>
          <span>Disponible</span>
        </div>

        <h1 class="hero-title">
          Gestion de parc informatique
          <span class="gradient-text">rapide et efficace</span>
        </h1>

        <p class="hero-description">
          Nous gérons votre parc informatique pour TPE, PME et professions libérales. Concentrez-vous sur votre cœur de métier, on s'occupe du reste.
        </p>

        <div class="hero-actions">
          <a href="https://meetings-eu1.hubspot.com/aubeut" target="_blank" rel="noopener" class="btn-hero-primary">
            Prendre rendez-vous
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M3 8h10M8 3l5 5-5 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </a>
          <button type="button" class="btn-hero-secondary" @click="scrollToPricing">
            Voir les tarifs
          </button>
        </div>

        <div class="stats-bar">
          <div class="stat">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke="currentColor"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
            </div>
            <div class="stat-value">4h</div>
            <div class="stat-label">Temps de résolution</div>
          </div>
          <div class="stat-divider"></div>
          <div class="stat">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke="currentColor"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            </div>
            <div class="stat-value">99%</div>
            <div class="stat-label">Disponibilité</div>
          </div>
          <div class="stat-divider"></div>
          <div class="stat">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            </div>
            <div class="stat-value">100%</div>
            <div class="stat-label">Cybersécurité</div>
          </div>
          <div class="stat-divider"></div>
          <div class="stat">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke="currentColor"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <div class="stat-value">&lt;2H</div>
            <div class="stat-label">Déploiement</div>
          </div>
        </div>
      </div>

      <!-- VISUEL 3D -->
      <div class="it-hero" aria-hidden="true">
        <svg class="it-connectors" viewBox="0 0 560 580" fill="none" xmlns="http://www.w3.org/2000/svg">
          <line x1="82" y1="118" x2="198" y2="155" stroke="#40FBDC" stroke-width="0.8" stroke-dasharray="4 3" opacity="0.35"/>
          <line x1="68" y1="248" x2="168" y2="255" stroke="#40FBDC" stroke-width="0.8" stroke-dasharray="4 3" opacity="0.35"/>
          <line x1="90" y1="390" x2="190" y2="350" stroke="#722695" stroke-width="0.8" stroke-dasharray="4 3" opacity="0.35"/>
          <line x1="446" y1="390" x2="370" y2="350" stroke="#722695" stroke-width="0.8" stroke-dasharray="4 3" opacity="0.35"/>
          <line x1="460" y1="160" x2="362" y2="155" stroke="#40FBDC" stroke-width="0.8" stroke-dasharray="4 3" opacity="0.35"/>
          <circle r="3" fill="#40FBDC" opacity="0.9"><animateMotion dur="2.2s" repeatCount="indefinite" begin="0s"><mpath href="#path-fw"/></animateMotion></circle>
          <circle r="3" fill="#40FBDC" opacity="0.8"><animateMotion dur="1.9s" repeatCount="indefinite" begin="0.7s"><mpath href="#path-ad"/></animateMotion></circle>
          <circle r="3" fill="#b060e0" opacity="0.9"><animateMotion dur="2.5s" repeatCount="indefinite" begin="0.3s"><mpath href="#path-pc"/></animateMotion></circle>
          <circle r="3" fill="#b060e0" opacity="0.8"><animateMotion dur="2.0s" repeatCount="indefinite" begin="1.1s"><mpath href="#path-lp"/></animateMotion></circle>
          <circle r="3" fill="#40FBDC" opacity="0.7"><animateMotion dur="2.3s" repeatCount="indefinite" begin="1.5s"><mpath href="#path-az"/></animateMotion></circle>
          <path id="path-fw" d="M82,118 L198,155" style="display:none"/>
          <path id="path-ad" d="M68,248 L168,255" style="display:none"/>
          <path id="path-pc" d="M90,390 L190,350" style="display:none"/>
          <path id="path-lp" d="M446,390 L370,350" style="display:none"/>
          <path id="path-az" d="M460,160 L362,155" style="display:none"/>
        </svg>

        <div class="it-scene">
          <div class="it-layers">
            <div class="it-layer it-layer--top">
              <div class="it-layer-inner">
                <span class="it-layer-label">.OS</span>
              </div>
            </div>
            <div class="it-layer it-layer--mid">
              <div class="it-layer-inner">
                <div class="it-layer-content">
                  <div class="it-srv-row">
                    <span class="it-srv-tag">FIREWALL</span>
                    <span class="it-srv-tag it-srv-tag--p">VLAN</span>
                  </div>
                  <div class="it-srv-row" style="margin-top:6px">
                    <span class="it-srv-tag">DMZ</span>
                    <span class="it-srv-tag it-srv-tag--dim">NSLOOKUP</span>
                  </div>
                </div>
                <span class="it-layer-label">.RESEAUX</span>
              </div>
            </div>
            <div class="it-layer it-layer--bot">
              <div class="it-layer-inner it-layer-inner--textured">
                <div class="it-core-icon">
                  <svg width="52" height="52" viewBox="0 0 52 52" fill="none">
                    <path d="M38.5 28.5L21.5 38.5C20.9 38.8 20.1 38.3 20.15 37.6L21.3 23.5C21.35 22.8 20.5 22.3 19.9 22.7L8.3 29.5C7.6 29.9 6.8 29.2 7.1 28.5L20.5 4.7C20.8 4 21.9 4.1 22.1 4.9L28.7 28.5C28.85 29.1 29.5 29.4 30.0 29.1L38.1 24.6C38.9 24.2 39.5 25.4 38.5 28.5Z" fill="url(#iconGrad)" opacity="0.9"/>
                    <defs>
                      <linearGradient id="iconGrad" x1="0" y1="0" x2="52" y2="52" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#40FBDC"/>
                        <stop offset="1" stop-color="#722695"/>
                      </linearGradient>
                    </defs>
                  </svg>
                </div>
                <span class="it-layer-label">.HARDWARE</span>
              </div>
            </div>
          </div>
        </div>

        <div class="it-badge it-badge--tl">
          <svg width="11" height="11" viewBox="0 0 11 11"><circle cx="5.5" cy="5.5" r="4.5" fill="none" stroke="#40FBDC" stroke-width="1" opacity=".6"/><circle cx="5.5" cy="5.5" r="2" fill="#40FBDC" opacity=".8"/></svg>
          LINUX
        </div>
        <div class="it-badge it-badge--ml">
          <svg width="11" height="11" viewBox="0 0 11 11"><rect x="1" y="2.5" width="9" height="6" rx="1.5" fill="none" stroke="#40FBDC" stroke-width="1" opacity=".6"/><rect x="3" y="4.5" width="5" height="2" rx=".5" fill="#40FBDC" opacity=".5"/></svg>
          NSLOOKUP
        </div>
        <div class="it-badge it-badge--bl">
          <svg width="11" height="11" viewBox="0 0 11 11"><rect x="2" y="1" width="7" height="9" rx="1.5" fill="none" stroke="#b060e0" stroke-width="1" opacity=".7"/><rect x="3.5" y="2.5" width="4" height="1.5" rx=".5" fill="#b060e0" opacity=".5"/><rect x="3.5" y="5" width="4" height="1" rx=".5" fill="#b060e0" opacity=".4"/></svg>
          THINKPAD
        </div>
        <div class="it-badge it-badge--br">
          <svg width="11" height="11" viewBox="0 0 11 11"><rect x="1" y="2" width="9" height="6" rx="1" fill="none" stroke="#b060e0" stroke-width="1" opacity=".7"/><rect x="3" y="4" width="5" height="2" rx=".5" fill="#b060e0" opacity=".4"/><rect x="3" y="9" width="5" height="1" rx=".5" fill="#b060e0" opacity=".3"/></svg>
          HPE
        </div>
        <div class="it-badge it-badge--tr">
          <svg width="11" height="11" viewBox="0 0 11 11"><circle cx="5.5" cy="5.5" r="4" fill="none" stroke="#40FBDC" stroke-width="1" opacity=".5" stroke-dasharray="2 2"/><text x="3.5" y="8" font-size="5" fill="#40FBDC" font-family="monospace">☁</text></svg>
          WINDOWS 11
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const scrollToPricing = () => {
  document.getElementById('pricing')?.scrollIntoView({ behavior: 'smooth' })
}
</script>

<style scoped>
.hero {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 80px 40px 40px;
  position: relative;
  overflow: hidden;
  background: #000;
}

.floating-orb {
  position: absolute;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(64,251,220,0.3), transparent);
  filter: blur(60px);
  pointer-events: none;
}

.orb-1 { width: 400px; height: 400px; top: 10%; left: 5%; animation: float1 20s ease-in-out infinite; }
.orb-2 { width: 350px; height: 350px; top: 60%; right: 10%; animation: float2 18s ease-in-out infinite; }
.orb-3 { width: 300px; height: 300px; bottom: 15%; left: 15%; animation: float3 22s ease-in-out infinite; }
.orb-4 { width: 250px; height: 250px; top: 30%; right: 20%; animation: float4 19s ease-in-out infinite; }
.orb-5 { width: 320px; height: 320px; bottom: 30%; right: 5%; animation: float5 21s ease-in-out infinite; }
.orb-6 { width: 280px; height: 280px; top: 50%; left: 40%; animation: float6 17s ease-in-out infinite; }

@keyframes float1 { 0%,100% { transform: translate(0,0) scale(1); opacity: 0.3; } 25% { transform: translate(50px,-40px) scale(1.1); opacity: 0.4; } 50% { transform: translate(-30px,30px) scale(0.9); opacity: 0.25; } 75% { transform: translate(30px,40px) scale(1.05); opacity: 0.35; } }
@keyframes float2 { 0%,100% { transform: translate(0,0) scale(1); opacity: 0.3; } 25% { transform: translate(-40px,50px) scale(0.95); opacity: 0.35; } 50% { transform: translate(30px,-30px) scale(1.05); opacity: 0.4; } 75% { transform: translate(-20px,-40px) scale(0.9); opacity: 0.3; } }
@keyframes float3 { 0%,100% { transform: translate(0,0) scale(1); opacity: 0.3; } 25% { transform: translate(40px,30px) scale(1.1); opacity: 0.4; } 50% { transform: translate(-50px,-20px) scale(0.85); opacity: 0.25; } 75% { transform: translate(20px,-30px) scale(1.05); opacity: 0.35; } }
@keyframes float4 { 0%,100% { transform: translate(0,0) scale(1); opacity: 0.3; } 25% { transform: translate(-30px,-50px) scale(0.9); opacity: 0.35; } 50% { transform: translate(40px,40px) scale(1.1); opacity: 0.4; } 75% { transform: translate(-40px,20px) scale(0.95); opacity: 0.3; } }
@keyframes float5 { 0%,100% { transform: translate(0,0) scale(1); opacity: 0.3; } 25% { transform: translate(30px,40px) scale(1.05); opacity: 0.4; } 50% { transform: translate(-40px,-30px) scale(0.9); opacity: 0.25; } 75% { transform: translate(50px,-20px) scale(1.1); opacity: 0.35; } }
@keyframes float6 { 0%,100% { transform: translate(0,0) scale(1); opacity: 0.3; } 25% { transform: translate(-50px,30px) scale(0.85); opacity: 0.35; } 50% { transform: translate(40px,-40px) scale(1.15); opacity: 0.4; } 75% { transform: translate(-30px,-50px) scale(0.95); opacity: 0.3; } }

.hero-inner {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 60px;
  align-items: center;
  max-width: 1200px;
  width: 100%;
  position: relative;
  z-index: 1;
}

.hero-content { max-width: 680px; }

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: rgba(64,251,220,0.1);
  border: 1px solid rgba(64,251,220,0.3);
  border-radius: 20px;
  font-size: 13px; font-weight: 600;
  color: #40FBDC;
  margin-bottom: 32px;
  animation: fadeInUp 0.8s ease-out;
}

.pulse-dot {
  width: 8px; height: 8px;
  background: #40FBDC; border-radius: 50%;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse { 0%,100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.5; transform: scale(1.2); } }

.hero-title {
  font-size: 72px; font-weight: 800; line-height: 1.1;
  margin-bottom: 24px; color: #fff; letter-spacing: -0.02em;
  animation: fadeInUp 0.8s ease-out 0.2s backwards;
}

.gradient-text {
  background: linear-gradient(135deg, #40FBDC, #00D9FF);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  background-clip: text; display: block;
}

.hero-description {
  font-size: 20px; line-height: 1.6;
  color: rgba(255,255,255,0.7);
  margin-bottom: 40px;
  animation: fadeInUp 0.8s ease-out 0.4s backwards;
}

@keyframes fadeInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

.hero-actions {
  display: flex; gap: 16px;
  margin-bottom: 48px;
  animation: fadeInUp 0.8s ease-out 0.6s backwards;
}

.btn-hero-primary {
  background: #40FBDC; color: #000; border: none;
  padding: 16px 32px; border-radius: 12px;
  font-size: 16px; font-weight: 600; cursor: pointer;
  display: inline-flex; align-items: center; gap: 10px;
  transition: all 0.3s; box-shadow: 0 8px 24px rgba(64,251,220,0.35);
  font-family: 'Inter', sans-serif; text-decoration: none;
}
.btn-hero-primary:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(64,251,220,0.5); }

.btn-hero-secondary {
  background: rgba(255,255,255,0.05); color: #fff;
  border: 1px solid rgba(255,255,255,0.15);
  padding: 16px 32px; border-radius: 12px;
  font-size: 16px; font-weight: 600; cursor: pointer;
  display: flex; align-items: center; gap: 10px;
  transition: all 0.3s; backdrop-filter: blur(10px);
  font-family: 'Inter', sans-serif;
}
.btn-hero-secondary:hover { background: rgba(255,255,255,0.1); border-color: rgba(255,255,255,0.3); }

.stats-bar {
  display: flex; align-items: center; justify-content: flex-start;
  gap: 32px; padding: 24px;
  background: rgba(255,255,255,0.03);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 16px; backdrop-filter: blur(10px);
  animation: fadeInUp 0.8s ease-out 0.8s backwards;
}

.stat { text-align: center; display: flex; flex-direction: column; align-items: center; gap: 8px; transition: all 0.3s; }

.stat-icon {
  width: 48px; height: 48px;
  background: linear-gradient(135deg, rgba(64,251,220,0.15), rgba(64,251,220,0.05));
  border: 1px solid rgba(64,251,220,0.2);
  border-radius: 12px; display: flex; align-items: center; justify-content: center;
  margin-bottom: 12px; transition: all 0.3s;
  color: #40FBDC;
}

.stat-value { font-size: 20px; font-weight: 700; color: #fff; margin-bottom: 4px; }
.stat-label { font-size: 12px; color: rgba(255,255,255,0.5); text-transform: uppercase; letter-spacing: 0.5px; }
.stat-divider { width: 1px; height: 80px; background: rgba(255,255,255,0.1); }

/* 3D Hero */
.it-hero { position: relative; width: 560px; height: 580px; display: flex; align-items: center; justify-content: center; }
.it-connectors { position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1; }
.it-scene { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; perspective: 900px; perspective-origin: 50% 38%; z-index: 2; }
.it-layers { position: relative; transform-style: preserve-3d; transform: rotateX(52deg) rotateZ(-18deg); animation: heroFloat 6s ease-in-out infinite; }
@keyframes heroFloat { 0%,100% { transform: rotateX(52deg) rotateZ(-18deg) translateY(0px); } 50% { transform: rotateX(52deg) rotateZ(-18deg) translateY(-14px); } }
.it-layer { position: absolute; left: 50%; top: 50%; transform-style: preserve-3d; }
.it-layer--bot { width: 260px; height: 180px; transform: translate(-50%, -50%) translateZ(0px); }
.it-layer--mid { width: 245px; height: 168px; transform: translate(-50%, -50%) translateZ(80px); }
.it-layer--top { width: 228px; height: 155px; transform: translate(-50%, -50%) translateZ(155px); }
.it-layer-inner { width: 100%; height: 100%; border-radius: 14px; position: relative; display: flex; align-items: center; justify-content: center; overflow: hidden; }
.it-layer--bot .it-layer-inner { background: #13131f; box-shadow: 0 0 0 1.5px rgba(114,38,149,0.7), 0 0 40px rgba(114,38,149,0.25), inset 0 0 40px rgba(64,251,220,0.03); }
.it-layer-inner--textured::before { content: ''; position: absolute; inset: 0; background-image: radial-gradient(circle, rgba(64,251,220,0.07) 1px, transparent 1px); background-size: 18px 18px; border-radius: 14px; }
.it-layer--mid .it-layer-inner { background: rgba(18,18,32,0.55); backdrop-filter: blur(12px); box-shadow: 0 0 0 1px rgba(64,251,220,0.35), 0 0 30px rgba(64,251,220,0.08); }
.it-layer--top .it-layer-inner { background: rgba(255,255,255,0.03); backdrop-filter: blur(8px); box-shadow: 0 0 0 1px rgba(64,251,220,0.2), 0 0 20px rgba(64,251,220,0.05); }
.it-layer-label { position: absolute; bottom: 10px; right: 14px; font-family: 'JetBrains Mono', monospace; font-size: 10px; letter-spacing: 0.12em; color: rgba(64,251,220,0.35); }
.it-layer--bot .it-layer-label { color: rgba(114,38,149,0.6); bottom: 12px; right: 16px; }
.it-core-icon { position: relative; z-index: 1; filter: drop-shadow(0 0 18px rgba(64,251,220,0.5)) drop-shadow(0 0 40px rgba(114,38,149,0.4)); animation: iconPulse 4s ease-in-out infinite; }
@keyframes iconPulse { 0%,100% { filter: drop-shadow(0 0 12px rgba(64,251,220,0.4)) drop-shadow(0 0 30px rgba(114,38,149,0.3)); } 50% { filter: drop-shadow(0 0 28px rgba(64,251,220,0.8)) drop-shadow(0 0 60px rgba(114,38,149,0.5)); } }
.it-layer-content { display: flex; flex-direction: column; align-items: center; }
.it-srv-row { display: flex; gap: 8px; }
.it-srv-tag { font-family: 'JetBrains Mono', monospace; font-size: 9px; letter-spacing: 0.1em; padding: 3px 8px; border-radius: 4px; background: rgba(64,251,220,0.06); border: 1px solid rgba(64,251,220,0.2); color: rgba(64,251,220,0.7); }
.it-srv-tag--p { background: rgba(114,38,149,0.08); border-color: rgba(114,38,149,0.3); color: rgba(176,96,224,0.8); }
.it-srv-tag--dim { background: rgba(64,251,220,0.03); border-color: rgba(64,251,220,0.1); color: rgba(64,251,220,0.4); }
.it-badge { position: absolute; z-index: 10; display: flex; align-items: center; gap: 6px; padding: 6px 11px; border-radius: 8px; font-family: 'JetBrains Mono', monospace; font-size: 10px; letter-spacing: 0.1em; background: rgba(13,13,26,0.85); border: 1px solid rgba(64,251,220,0.22); color: rgba(64,251,220,0.75); backdrop-filter: blur(10px); box-shadow: 0 4px 20px rgba(0,0,0,0.4); animation: badgeFloat 5s ease-in-out infinite; }
.it-badge--bl, .it-badge--br { border-color: rgba(114,38,149,0.3); color: rgba(176,96,224,0.8); }
@keyframes badgeFloat { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-5px); } }
.it-badge--tl { top: 102px; left: 20px; animation-delay: 0s; }
.it-badge--ml { top: 234px; left: 6px; animation-delay: -1.2s; }
.it-badge--bl { top: 374px; left: 28px; animation-delay: -2.5s; }
.it-badge--br { top: 374px; right: 28px; animation-delay: -3.8s; }
.it-badge--tr { top: 144px; right: 14px; animation-delay: -0.8s; }

@media (max-width: 1200px) {
  .it-hero { width: 420px; height: 440px; transform: scale(0.82); transform-origin: center; flex-shrink: 0; }
}
@media (max-width: 1024px) {
  .hero-inner { grid-template-columns: 1fr; }
  .it-hero { display: none; }
}
@media (max-width: 768px) {
  .hero { padding: 100px 24px 40px; }
  .hero-title { font-size: 42px; }
  .hero-description { font-size: 16px; }
  .hero-actions { flex-direction: column; }
  .btn-hero-primary, .btn-hero-secondary { width: 100%; justify-content: center; }
  .stats-bar { flex-wrap: wrap; gap: 20px; }
  .stat-divider { display: none; }
  .floating-orb { filter: blur(40px); }
  .orb-1 { width: 250px; height: 250px; }
  .orb-2 { width: 220px; height: 220px; }
}
</style>