<template>
  <section id="pricing" class="pricing-section">
    <div class="section-header">
      <div class="section-tag">Tarifs</div>
      <h2>Un prix juste, par poste</h2>
      <p>Plus votre structure grandit, moins vous payez par poste. Sans engagement, résiliable à tout moment.</p>
    </div>

    <div class="pricing-tiers">
      <div class="tier-card">
        <div class="tier-label">Indépendant / Micro</div>
        <div class="tier-range">1 – 3 postes</div>
        <div class="tier-price">
          <span class="tier-amount">79 €</span>
          <span class="tier-unit">/ poste / mois</span>
        </div>
        <div class="tier-total-hint">Exemple : 3 postes = 237 €/mois</div>
      </div>

      <div class="tier-card tier-card--featured">
        <div class="tier-badge">Le plus courant</div>
        <div class="tier-label">TPE / PME</div>
        <div class="tier-range">4 – 10 postes</div>
        <div class="tier-price">
          <span class="tier-amount">65 €</span>
          <span class="tier-unit">/ poste / mois</span>
        </div>
        <div class="tier-total-hint">Exemple : 8 postes = 520 €/mois</div>
      </div>

      <div class="tier-card">
        <div class="tier-label">PME / Entreprise</div>
        <div class="tier-range">11 – 20 postes</div>
        <div class="tier-price">
          <span class="tier-amount">55 €</span>
          <span class="tier-unit">/ poste / mois</span>
        </div>
        <div class="tier-total-hint">Exemple : 15 postes = 825 €/mois</div>
      </div>

      <div class="tier-card">
        <div class="tier-label">Multi-sites</div>
        <div class="tier-range">20+ postes</div>
        <div class="tier-price">
          <span class="tier-amount">Sur devis</span>
        </div>
        <div class="tier-total-hint">Tarif négocié selon périmètre</div>
      </div>
    </div>

    <div class="pricing-included">
      <div class="included-title">Inclus dans toutes les formules</div>
      <div class="included-grid">
        <div v-for="item in included" :key="item" class="included-item">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M5 8l2 2 4-4" stroke="#40FBDC" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
          {{ item }}
        </div>
      </div>
      <div class="included-cta">
        <a href="https://meetings-eu1.hubspot.com/aubeut" target="_blank" rel="noopener" class="btn-hero-primary">
          Obtenir un devis personnalisé
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M8 3l5 5-5 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </a>
      </div>
    </div>
  </section>
</template>

<script setup>
const included = [
  'Supervision 24/7',
  'Antivirus managé',
  'Mises à jour automatiques',
  'Sauvegarde quotidienne',
  'Support à distance (réponse <4h)',
  'Rapport mensuel d\'activité'
]
</script>

<style scoped>
.pricing-section { padding: 120px 40px; max-width: 1400px; margin: 0 auto; }

.section-header { text-align: center; margin-bottom: 80px; }
.section-tag { display: inline-block; padding: 6px 14px; background: rgba(64,251,220,0.1); border: 1px solid rgba(64,251,220,0.3); border-radius: 20px; font-size: 12px; font-weight: 700; color: #40FBDC; letter-spacing: 1px; margin-bottom: 20px; text-transform: uppercase; }
.section-header h2 { font-size: 48px; font-weight: 800; margin-bottom: 16px; letter-spacing: -0.02em; color: #fff; }
.section-header p { font-size: 18px; color: rgba(255,255,255,0.6); max-width: 600px; margin: 0 auto; line-height: 1.6; }

.pricing-tiers { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 48px; }

.tier-card { background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; padding: 32px 28px; position: relative; transition: all 0.4s; text-align: center; }
.tier-card:hover { transform: translateY(-4px); box-shadow: 0 16px 50px rgba(64,251,220,0.12); border-color: rgba(64,251,220,0.25); }
.tier-card--featured { border-color: rgba(64,251,220,0.4); background: rgba(64,251,220,0.04); box-shadow: 0 20px 60px rgba(64,251,220,0.15); }

.tier-badge { position: absolute; top: -13px; left: 50%; transform: translateX(-50%); background: #40FBDC; color: #000; padding: 5px 14px; border-radius: 20px; font-size: 11px; font-weight: 700; white-space: nowrap; box-shadow: 0 4px 12px rgba(64,251,220,0.4); }

.tier-label { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: rgba(255,255,255,0.45); margin-bottom: 6px; }
.tier-range { font-size: 17px; font-weight: 700; color: #fff; margin-bottom: 24px; }
.tier-price { margin-bottom: 10px; }
.tier-amount { font-size: 42px; font-weight: 800; color: #fff; display: block; line-height: 1; }
.tier-card--featured .tier-amount { background: linear-gradient(135deg, #40FBDC, #00D9FF); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.tier-unit { font-size: 13px; color: rgba(255,255,255,0.45); display: block; margin-top: 6px; }
.tier-total-hint { font-size: 12px; color: rgba(255,255,255,0.3); background: rgba(255,255,255,0.04); border-radius: 8px; padding: 8px 12px; margin-top: 16px; }

.pricing-included { background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.08); border-radius: 20px; padding: 40px 48px; }
.included-title { font-size: 16px; font-weight: 700; color: rgba(255,255,255,0.7); text-align: center; margin-bottom: 28px; text-transform: uppercase; letter-spacing: 0.8px; }
.included-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px 32px; margin-bottom: 36px; }
.included-item { display: flex; align-items: center; gap: 10px; font-size: 15px; color: rgba(255,255,255,0.75); }
.included-cta { text-align: center; }

.btn-hero-primary { background: #40FBDC; color: #000; border: none; padding: 16px 32px; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 10px; transition: all 0.3s; box-shadow: 0 8px 24px rgba(64,251,220,0.35); font-family: 'Inter', sans-serif; text-decoration: none; }
.btn-hero-primary:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(64,251,220,0.5); }

@media (max-width: 1100px) { .pricing-tiers { grid-template-columns: repeat(2, 1fr); } .included-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { .pricing-section { padding: 80px 24px; } .section-header { margin-bottom: 48px; } .section-header h2 { font-size: 36px; } .pricing-tiers { grid-template-columns: 1fr; } .included-grid { grid-template-columns: 1fr; } .pricing-included { padding: 28px 24px; } }
</style>