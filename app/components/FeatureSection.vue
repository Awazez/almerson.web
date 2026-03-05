<template>
  <section id="features" class="features-section">
    <div class="section-header">
      <div class="section-tag">Services proposés</div>
      <h2>Construire un parc moderne</h2>
      <p>Tout ce dont vous avez besoin pour gérer votre informatique sereinement</p>
    </div>

    <div class="features-grid">
      <div v-for="feature in features" :key="feature.title" class="feature-card">
        <div class="feature-icon-wrapper">
          <div class="feature-icon" v-html="feature.icon"></div>
        </div>
        <div class="feature-shine"></div>
        <h3>{{ feature.title }}</h3>
        <p>{{ feature.description }}</p>
      </div>
    </div>
  </section>
</template>

<script setup>
const features = [
  {
    title: 'Déploiement rapide',
    description: 'Installation et configuration de postes, serveurs et périphériques en moins de 2 heures, sans interrompre votre activité.',
    icon: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#40FBDC" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>`
  },
  {
    title: 'Cybersécurité',
    description: 'Pare-feu, antivirus managé, mises à jour automatiques et audit de sécurité pour protéger vos données et celles de vos clients.',
    icon: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#40FBDC" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>`
  },
  {
    title: 'Réseau & connectivité',
    description: 'Configuration Wi-Fi, VPN, VLAN et firewall. Un réseau sécurisé et performant, adapté à votre croissance.',
    icon: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#40FBDC" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>`
  },
  {
    title: 'Supervision 24/7',
    description: 'Surveillance en temps réel de vos équipements avec alertes intelligentes. On détecte les pannes avant que vous ne les ressentiez.',
    icon: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#40FBDC" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>`
  },
  {
    title: 'Sauvegarde automatique',
    description: 'Sauvegardes quotidiennes chiffrées avec restauration rapide. Vos données sont protégées, même en cas de sinistre ou de ransomware.',
    icon: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#40FBDC" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v6m0 6v6"/><path d="m4.2 4.2 4.2 4.2m5.6 5.6 4.2 4.2"/><path d="M1 12h6m6 0h6"/><path d="m4.2 19.8 4.2-4.2m5.6-5.6 4.2-4.2"/></svg>`
  },
  {
    title: 'Support & helpdesk',
    description: 'Un interlocuteur unique, joignable rapidement. Interventions à distance ou sur site selon la criticité de votre incident.',
    icon: `<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#40FBDC" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>`
  }
]
</script>

<style scoped>
.features-section { padding: 120px 40px; max-width: 1400px; margin: 0 auto; }

.section-header { text-align: center; margin-bottom: 80px; }
.section-tag { display: inline-block; padding: 6px 14px; background: rgba(64,251,220,0.1); border: 1px solid rgba(64,251,220,0.3); border-radius: 20px; font-size: 12px; font-weight: 700; color: #40FBDC; letter-spacing: 1px; margin-bottom: 20px; text-transform: uppercase; }
.section-header h2 { font-size: 48px; font-weight: 800; margin-bottom: 16px; letter-spacing: -0.02em; color: #fff; }
.section-header p { font-size: 18px; color: rgba(255,255,255,0.6); max-width: 600px; margin: 0 auto; line-height: 1.6; }

.features-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 32px; }

.feature-card {
  background: rgba(255,255,255,0.02);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 16px; padding: 36px;
  position: relative; overflow: hidden;
  transition: all 0.4s cubic-bezier(0.4,0,0.2,1);
}
.feature-card:hover { background: rgba(255,255,255,0.04); border-color: rgba(64,251,220,0.3); transform: translateY(-4px); box-shadow: 0 12px 40px rgba(64,251,220,0.15); }
.feature-card:hover .feature-shine { transform: translateX(200%); }

.feature-shine { position: absolute; top: 0; left: -100%; width: 100%; height: 100%; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent); transition: transform 0.6s; pointer-events: none; }

.feature-icon-wrapper { width: 56px; height: 56px; background: linear-gradient(135deg, rgba(64,251,220,0.1), rgba(64,251,220,0.05)); border: 1px solid rgba(64,251,220,0.2); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; transition: all 0.3s; }
.feature-card:hover .feature-icon-wrapper { background: linear-gradient(135deg, rgba(64,251,220,0.2), rgba(64,251,220,0.1)); border-color: rgba(64,251,220,0.4); box-shadow: 0 8px 20px rgba(64,251,220,0.2); }
.feature-icon { display: flex; align-items: center; justify-content: center; }

.feature-card h3 { font-size: 20px; font-weight: 700; margin-bottom: 12px; color: #fff; }
.feature-card p { color: rgba(255,255,255,0.6); line-height: 1.7; font-size: 15px; }

@media (max-width: 1200px) { .features-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { .features-section { padding: 80px 24px; } .section-header { margin-bottom: 48px; } .section-header h2 { font-size: 36px; } .features-grid { grid-template-columns: 1fr; gap: 24px; } .feature-card { padding: 28px; } }
</style>