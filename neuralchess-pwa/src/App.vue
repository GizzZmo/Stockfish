<template>
  <div class="app">
    <div class="app-background"></div>

    <header class="app-header glass-card">
      <div class="header-content">
        <div class="logo-section">
          <div class="logo">♛</div>
          <div>
            <p class="eyebrow">Stockfish in the browser</p>
            <h1 class="title">NeuralChess PWA</h1>
          </div>
        </div>

        <div class="status-pill glass-card subtle">
          <span class="status-dot" :class="{ online: isOnline }"></span>
          <span>{{ isOnline ? 'Online ready' : 'Offline mode' }}</span>
        </div>
      </div>
    </header>

    <main class="app-main">
      <section class="board-section">
        <div class="board-container glass-card">
          <div class="chess-board" role="img" aria-label="Decorative chess board preview">
            <div
              v-for="square in squares"
              :key="square.name"
              class="chess-square"
              :class="square.color"
            >
              <span class="square-label">{{ square.name }}</span>
              <span class="piece">{{ square.piece }}</span>
            </div>
          </div>
        </div>

        <div class="hero-copy glass-card">
          <div class="hero-actions">
            <button class="control-btn primary" type="button">Launch analysis</button>
            <button class="control-btn" type="button">Install PWA</button>
          </div>
          <p>
            A responsive, glassmorphism-inspired shell for a future Stockfish-powered
            web experience. This preview is intentionally lightweight so the PWA can
            build reliably in CI while still producing representative screenshots.
          </p>
        </div>
      </section>

      <aside class="side-panel">
        <section class="panel-section glass-card">
          <h2>Highlights</h2>
          <ul class="feature-list">
            <li>Responsive desktop and mobile layouts</li>
            <li>Offline-ready progressive web app shell</li>
            <li>Stockfish-focused branding and presentation</li>
          </ul>
        </section>

        <section class="panel-section glass-card">
          <h2>Planned modules</h2>
          <div class="module-grid">
            <div class="module-card">
              <strong>Board UI</strong>
              <span>Interactive move input and history</span>
            </div>
            <div class="module-card">
              <strong>Engine</strong>
              <span>WebAssembly-backed analysis controls</span>
            </div>
            <div class="module-card">
              <strong>Themes</strong>
              <span>Adaptive light and dark glass presets</span>
            </div>
          </div>
        </section>
      </aside>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useOnline } from '@vueuse/core'

const isOnline = useOnline()
const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
const pieces = {
  a8: '♜',
  b8: '♞',
  c8: '♝',
  d8: '♛',
  e8: '♚',
  f8: '♝',
  g8: '♞',
  h8: '♜',
  a7: '♟',
  b7: '♟',
  c7: '♟',
  d7: '♟',
  e7: '♟',
  f7: '♟',
  g7: '♟',
  h7: '♟',
  c6: '♘',
  f3: '♙',
  a2: '♙',
  b2: '♙',
  c2: '♙',
  d2: '♙',
  e2: '♙',
  g2: '♙',
  h2: '♙',
  a1: '♖',
  b1: '♘',
  c1: '♗',
  d1: '♕',
  e1: '♔',
  f1: '♗',
  g1: '♘',
  h1: '♖',
}

const squares = computed(() =>
  Array.from({ length: 8 }, (_, rankIndex) => {
    const rank = 8 - rankIndex

    return files.map((file, fileIndex) => {
      const name = `${file}${rank}`
      return {
        name,
        color: (rankIndex + fileIndex) % 2 === 0 ? 'light' : 'dark',
        piece: pieces[name] ?? '',
      }
    })
  }).flat(),
)
</script>

<style scoped>
.app {
  min-height: 100vh;
  display: grid;
  grid-template-rows: auto 1fr;
  gap: 1rem;
  padding: 1rem;
  position: relative;
}

.app-background {
  position: fixed;
  inset: 0;
  background:
    radial-gradient(circle at top left, rgba(255, 255, 255, 0.18), transparent 35%),
    linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  z-index: -1;
}

.app-header,
.hero-copy,
.panel-section {
  padding: 1.25rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  max-width: 1400px;
  margin: 0 auto;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo {
  width: 3rem;
  height: 3rem;
  display: grid;
  place-items: center;
  border-radius: 0.75rem;
  background: linear-gradient(135deg, #60a5fa, #34d399);
  color: white;
  font-size: 1.75rem;
  box-shadow: 0 10px 30px rgba(52, 211, 153, 0.35);
}

.eyebrow {
  margin: 0 0 0.25rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-size: 0.75rem;
}

.title {
  margin: 0;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: 999px;
}

.status-dot {
  width: 0.7rem;
  height: 0.7rem;
  border-radius: 50%;
  background: #f87171;
  box-shadow: 0 0 0 0.2rem rgba(248, 113, 113, 0.18);
}

.status-dot.online {
  background: #34d399;
  box-shadow: 0 0 0 0.2rem rgba(52, 211, 153, 0.18);
}

.app-main {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 1.5rem;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
}

.board-section,
.side-panel {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.board-container {
  padding: 1.5rem;
}

.chess-board {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  width: min(100%, 720px);
  aspect-ratio: 1;
  margin: 0 auto;
  border-radius: 1rem;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.25);
  box-shadow: 0 20px 50px rgba(31, 38, 135, 0.35);
}

.chess-square {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: clamp(1rem, 2.4vw, 2.6rem);
}

.chess-square.light {
  background: rgba(255, 255, 255, 0.88);
  color: #111827;
}

.chess-square.dark {
  background: rgba(37, 99, 235, 0.55);
  color: white;
}

.square-label {
  position: absolute;
  top: 0.35rem;
  left: 0.4rem;
  font-size: 0.65rem;
  opacity: 0.75;
}

.piece {
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.25);
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.control-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.7rem 1rem;
  border-radius: 0.75rem;
  border: 1px solid rgba(255, 255, 255, 0.18);
  background: rgba(255, 255, 255, 0.1);
  color: var(--text-primary);
  font-weight: 600;
  transition: transform 0.2s ease, background 0.2s ease;
}

.control-btn:hover {
  transform: translateY(-1px);
  background: rgba(255, 255, 255, 0.16);
}

.control-btn.primary {
  background: linear-gradient(135deg, #60a5fa, #34d399);
  border-color: transparent;
  color: white;
}

.feature-list {
  margin: 0;
  padding-left: 1.2rem;
  color: var(--text-secondary);
}

.feature-list li + li {
  margin-top: 0.75rem;
}

.module-grid {
  display: grid;
  gap: 0.75rem;
}

.module-card {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  padding: 0.9rem 1rem;
  border-radius: 0.85rem;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.module-card span {
  color: var(--text-secondary);
  font-size: 0.92rem;
}

@media (max-width: 900px) {
  .app-main {
    grid-template-columns: 1fr;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
  }
}

@media (max-width: 480px) {
  .app {
    padding: 0.75rem;
  }

  .board-container,
  .app-header,
  .hero-copy,
  .panel-section {
    padding: 1rem;
  }

  .logo {
    width: 2.5rem;
    height: 2.5rem;
    font-size: 1.4rem;
  }
}
</style>
