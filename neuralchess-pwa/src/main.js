import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

// Import global styles
import './styles/glassmorphism.css'
import './styles/animations.css'
import './styles/responsive.css'

// Create Vue app
const app = createApp(App)

// Add Pinia for state management
app.use(createPinia())

// Mount the app
app.mount('#app')

// Register service worker for PWA functionality
if ('serviceWorker' in navigator && import.meta.env.PROD) {
  navigator.serviceWorker.register('/sw.js')
    .then((registration) => {
      console.log('SW registered: ', registration)
    })
    .catch((registrationError) => {
      console.log('SW registration failed: ', registrationError)
    })
}