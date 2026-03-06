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
        { property: 'og:title', content: 'Almerson – Infogérance & Gestion de Parc Informatique' },
        { property: 'og:description', content: 'Almerson prend en charge votre parc informatique : Active Directory, cybersécurité, sauvegardes, réseau et supervision 24h/24.' },
        { property: 'og:url', content: 'https://www.almerson.com' },
        { property: 'og:type', content: 'website' },
        { property: 'og:locale', content: 'fr_FR' },
      ],
      link: [
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
        { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700;800&display=swap' },
        { rel: 'canonical', href: 'https://www.almerson.com' },
      ],
      script: [
        {
          type: 'application/ld+json',
          innerHTML: JSON.stringify({
            '@context': 'https://schema.org',
            '@graph': [
              {
                '@type': 'Organization',
                '@id': 'https://www.almerson.com/#organization',
                name: 'Almerson',
                url: 'https://www.almerson.com',
                logo: {
                  '@type': 'ImageObject',
                  url: 'https://www.almerson.com/favicon.ico',
                },
                description: 'Infogérance et gestion de parc informatique pour TPE, PME et professions libérales en Normandie.',
                address: {
                  '@type': 'PostalAddress',
                  addressLocality: 'Caen',
                  addressRegion: 'Normandie',
                  addressCountry: 'FR',
                },
                contactPoint: {
                  '@type': 'ContactPoint',
                  contactType: 'customer service',
                  url: 'https://meetings-eu1.hubspot.com/aubeut',
                  availableLanguage: 'French',
                },
                sameAs: [],
              },
              {
                '@type': 'WebSite',
                '@id': 'https://www.almerson.com/#website',
                url: 'https://www.almerson.com',
                name: 'Almerson',
                description: 'Infogérance & Gestion de Parc Informatique pour TPE et PME',
                publisher: { '@id': 'https://www.almerson.com/#organization' },
                inLanguage: 'fr-FR',
              },
              {
                '@type': 'WebPage',
                '@id': 'https://www.almerson.com/#webpage',
                url: 'https://www.almerson.com',
                name: 'Almerson – Infogérance & Gestion de Parc Informatique pour TPE et PME',
                isPartOf: { '@id': 'https://www.almerson.com/#website' },
                about: { '@id': 'https://www.almerson.com/#organization' },
                description: 'Almerson prend en charge votre parc informatique : Active Directory, cybersécurité, sauvegardes, réseau et supervision 24h/24.',
                inLanguage: 'fr-FR',
              },
              {
                '@type': 'LocalBusiness',
                '@id': 'https://www.almerson.com/#localbusiness',
                name: 'Almerson',
                url: 'https://www.almerson.com',
                description: 'Infogérance et cybersécurité pour TPE, PME et professions libérales.',
                address: {
                  '@type': 'PostalAddress',
                  addressLocality: 'Caen',
                  addressRegion: 'Normandie',
                  addressCountry: 'FR',
                },
                areaServed: { '@type': 'State', name: 'Normandie' },
                priceRange: '€€',
              },
            ],
          }),
        },
      ],
    }
  }
})