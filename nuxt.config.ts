// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  devServer: {
    host: '0.0.0.0',
  },

  vite: {
    server: {
      hmr: {
        clientPort: 443,
        protocol: 'wss',
      }
    }
  },

  css: ['~/assets/css/main.css'],

  app: {
    head: {
      title: 'Almerson – Infogérance & Gestion de Parc Informatique pour TPE et PME',
      meta: [
        { name: 'description', content: 'Almerson prend en charge votre parc informatique : Active Directory, cybersécurité, sauvegardes, réseau et supervision 24h/24. Solutions sur-mesure pour TPE, PME et professions libérales en Normandie.' },
        { name: 'robots', content: 'index, follow' },
      ],
      link: [
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700;800&display=swap' },
      ]
    }
  }
})