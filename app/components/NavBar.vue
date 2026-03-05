<template>
  <nav class="navbar" aria-label="Navigation principale">
    <div class="nav-content">
      <NuxtLink to="/" class="logo" aria-label="Almerson – Retour à l'accueil">
        <div class="logo-symbol">
          <svg width="1847" height="2133" viewBox="0 0 1847 2133" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
            <path d="M1829.85 1462.98L678.199 2127.48C654.042 2141.42 623.746 2121.67 625.803 2093.33L677.898 1375.48C679.971 1346.91 649.224 1327.17 625.081 1341.57L53.0338 1682.85C24.6865 1699.76 -9.52093 1670.02 2.45834 1638.88L624.522 21.7628C636.655 -9.77734 681.886 -6.17938 690.534 27.0136L1044.03 1383.89C1048.22 1399.97 1062.81 1411.2 1079.1 1410.89L1810.64 1397.01C1846.74 1396.33 1860.93 1445.05 1829.85 1462.98Z" fill="url(#paint0_linear_nav)"/>
            <defs>
              <linearGradient id="paint0_linear_nav" x1="174.934" y1="908.779" x2="1957.28" y2="1360.64" gradientUnits="userSpaceOnUse">
                <stop stop-color="#40FBDC"/>
                <stop offset="1" stop-color="#722695"/>
              </linearGradient>
            </defs>
          </svg>
        </div>
        <span class="logo-text">Almerson</span>
      </NuxtLink>

      <div class="nav-center">
        <a href="#features">Services</a>
        <a href="#pricing">Tarifs</a>
        <a href="#tech">Technologies</a>
        <a href="#contact">Contact</a>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.navbar {
  position: fixed;
  top: 0; left: 0; right: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  z-index: 100;
}

.nav-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 14px 40px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  text-decoration: none;
}

.logo-symbol { width: 38px; height: 38px; display: flex; align-items: center; justify-content: center; }
.logo-symbol svg { width: 100%; height: 100%; filter: drop-shadow(0 0 8px rgba(64,251,220,0.4)); transition: filter 0.3s; }
.logo:hover .logo-symbol svg { filter: drop-shadow(0 0 16px rgba(64,251,220,0.8)); }

.logo-text {
  font-family: 'Montserrat', sans-serif;
  font-weight: 700;
  font-size: 18px;
  letter-spacing: -0.5px;
  color: #fff;
  text-shadow: 0 0 20px rgba(64,251,220,0.3);
}

.nav-center { display: flex; gap: 32px; }

.nav-center a {
  color: rgba(255,255,255,0.7);
  font-size: 14px;
  font-weight: 500;
  transition: color 0.2s;
  position: relative;
  text-decoration: none;
}

.nav-center a::after {
  content: '';
  position: absolute;
  bottom: -6px; left: 0;
  width: 0; height: 2px;
  background: #40FBDC;
  transition: width 0.3s;
}

.nav-center a:hover { color: #fff; }
.nav-center a:hover::after { width: 100%; }

@media (max-width: 768px) {
  .nav-content { padding: 14px 24px; }
  .nav-center { display: none; }
  .logo-symbol { width: 32px; height: 32px; }
  .logo-text { font-size: 16px; }
}
</style>