<template>
  <section class="cta-section">
    <div class="cta-card">
      <div class="cta-content">
        <h2>Prêt à nous confier votre parc ?</h2>
        <p>Un diagnostic gratuit de 30 minutes pour évaluer vos besoins et vous proposer la formule adaptée.</p>
        <div class="cta-actions">
          <a href="https://meetings-eu1.hubspot.com/aubeut" target="_blank" rel="noopener" class="btn-cta-primary">
            Prendre rendez-vous
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M8 3l5 5-5 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
          </a>
          <button type="button" class="btn-cta-secondary" @click="scrollToPricing">Voir les tarifs</button>
        </div>
      </div>
      <div class="cta-visual">
        <div class="stats-grid-cta">
          <div v-for="stat in stats" :key="stat.label" class="stat-card">
            <div class="stat-number">{{ stat.value }}</div>
            <div class="stat-text">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const scrollToPricing = () => {
  document.getElementById('pricing')?.scrollIntoView({ behavior: 'smooth' })
}

const stats = [
  { value: '<4h', label: 'Temps de réponse' },
  { value: '99%', label: 'Satisfaction client' },
  { value: '24/7', label: 'Supervision' },
  { value: '2', label: 'Ans d\'expérience' }
]
</script>

<style scoped>
.cta-section { padding: 120px 40px; max-width: 1400px; margin: 0 auto; }

.cta-card { background: linear-gradient(135deg, rgba(64,251,220,0.1), rgba(64,251,220,0.05)); border: 1px solid rgba(64,251,220,0.3); border-radius: 24px; padding: 80px 60px; display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center; position: relative; overflow: hidden; }
.cta-card::before { content: ''; position: absolute; top: -50%; right: -50%; width: 100%; height: 100%; background: radial-gradient(circle, rgba(64,251,220,0.2), transparent); pointer-events: none; }

.cta-content h2 { font-size: 48px; font-weight: 800; margin-bottom: 16px; letter-spacing: -0.02em; color: #fff; }
.cta-content p { font-size: 18px; color: rgba(255,255,255,0.6); margin-bottom: 32px; line-height: 1.6; }
.cta-actions { display: flex; gap: 16px; flex-wrap: wrap; }

.btn-cta-primary { background: #40FBDC; color: #000; border: none; padding: 16px 32px; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 10px; transition: all 0.3s; box-shadow: 0 8px 24px rgba(64,251,220,0.35); font-family: 'Inter', sans-serif; text-decoration: none; }
.btn-cta-primary:hover { transform: translateY(-2px); box-shadow: 0 12px 32px rgba(64,251,220,0.5); }

.btn-cta-secondary { background: rgba(255,255,255,0.05); color: #fff; border: 1px solid rgba(255,255,255,0.15); padding: 16px 32px; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s; font-family: 'Inter', sans-serif; }
.btn-cta-secondary:hover { background: rgba(255,255,255,0.1); }

.stats-grid-cta { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }

.stat-card { background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; padding: 24px; text-align: center; backdrop-filter: blur(10px); transition: all 0.3s; }
.stat-card:hover { transform: translateY(-2px); border-color: rgba(64,251,220,0.3); }

.stat-number { font-size: 32px; font-weight: 800; background: linear-gradient(135deg, #fff, rgba(255,255,255,0.6)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 8px; }
.stat-text { font-size: 13px; color: rgba(255,255,255,0.5); text-transform: uppercase; letter-spacing: 0.5px; }

@media (max-width: 768px) { .cta-section { padding: 80px 24px; } .cta-card { grid-template-columns: 1fr; padding: 60px 32px; gap: 40px; } .cta-content h2 { font-size: 36px; } .cta-actions { flex-direction: column; } .btn-cta-primary, .btn-cta-secondary { width: 100%; justify-content: center; } }
</style>