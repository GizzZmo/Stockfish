<template>
  <div id="app" class="app">
    <!-- Background gradient -->
    <div class="app-background"></div>
    
    <!-- Header -->
    <header class="app-header glass-card">
      <div class="header-content">
        <div class="logo-section">
          <div class="logo">♛</div>
          <h1 class="title">NeuralChess</h1>
        </div>
        
        <div class="header-controls">
          <ThemeSelector />
          <button 
            class="control-btn"
            @click="toggleEnginePanel"
            :aria-pressed="showEnginePanel"
          >
            <span class="btn-icon">⚙️</span>
            <span class="btn-text">Engine</span>
          </button>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main class="app-main">
      <!-- Chess board section -->
      <section class="board-section">
        <div class="board-container glass-card">
          <ChessBoard 
            :position="gameState.position"
            :orientation="gameState.orientation"
            :lastMove="gameState.lastMove"
            :legalMoves="gameState.legalMoves"
            @move="handleMove"
          />
        </div>
        
        <!-- Game controls -->
        <div class="game-controls glass-card">
          <button 
            class="control-btn primary"
            @click="newGame"
          >
            <span class="btn-icon">🆕</span>
            <span class="btn-text">New Game</span>
          </button>
          
          <button 
            class="control-btn"
            @click="flipBoard"
          >
            <span class="btn-icon">🔄</span>
            <span class="btn-text">Flip</span>
          </button>
          
          <button 
            class="control-btn"
            @click="undoMove"
            :disabled="!canUndo"
          >
            <span class="btn-icon">↶</span>
            <span class="btn-text">Undo</span>
          </button>
        </div>
      </section>

      <!-- Side panel -->
      <aside class="side-panel">
        <!-- Game history -->
        <div class="panel-section">
          <GameHistory 
            :moves="gameState.history"
            :currentMoveIndex="gameState.currentMoveIndex"
            @goto-move="gotoMove"
          />
        </div>
        
        <!-- Engine panel (collapsible) -->
        <div 
          class="panel-section engine-panel"
          :class="{ expanded: showEnginePanel }"
        >
          <EnginePanel 
            v-if="showEnginePanel"
            :analysis="engineState.analysis"
            :isAnalyzing="engineState.isAnalyzing"
            :depth="engineState.depth"
            @start-analysis="startAnalysis"
            @stop-analysis="stopAnalysis"
            @set-depth="setEngineDepth"
          />
        </div>
      </aside>
    </main>

    <!-- Status bar -->
    <footer class="app-footer glass-card">
      <div class="status-section">
        <span class="status-item">
          <span class="status-label">Turn:</span>
          <span class="status-value">{{ gameState.turn === 'w' ? 'White' : 'Black' }}</span>
        </span>
        
        <span class="status-item">
          <span class="status-label">Engine:</span>
          <span 
            class="status-value"
            :class="{ 
              'status-ready': engineState.isReady,
              'status-error': engineState.error
            }"
          >
            {{ engineStatusText }}
          </span>
        </span>
      </div>
      
      <div class="connection-indicator" :class="{ online: isOnline }"></div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useOnline } from '@vueuse/core'
import ChessBoard from './components/ChessBoard.vue'
import GameHistory from './components/GameHistory.vue'
import EnginePanel from './components/EnginePanel.vue'
import ThemeSelector from './components/ThemeSelector.vue'
import { useChessGame } from './composables/useChessGame'
import { useEngine } from './composables/useEngine'

// Composables
const isOnline = useOnline()
const { gameState, newGame, makeMove, undoMove, flipBoard, gotoMove, canUndo } = useChessGame()
const { engineState, startAnalysis, stopAnalysis, setEngineDepth, initializeEngine } = useEngine()

// Local state
const showEnginePanel = ref(true)

// Computed
const engineStatusText = computed(() => {
  if (engineState.error) return 'Error'
  if (!engineState.isReady) return 'Loading...'
  if (engineState.isAnalyzing) return 'Analyzing...'
  return 'Ready'
})

// Methods
const toggleEnginePanel = () => {
  showEnginePanel.value = !showEnginePanel.value
}

const handleMove = (move) => {
  makeMove(move)
  // Start analysis after player move
  if (engineState.isReady && gameState.value.turn !== gameState.value.playerColor) {
    startAnalysis(gameState.value.position)
  }
}

// Lifecycle
onMounted(async () => {
  await initializeEngine()
  newGame()
})
</script>

<style scoped>
.app {
  min-height: 100vh;
  display: grid;
  grid-template-rows: auto 1fr auto;
  gap: 1rem;
  padding: 1rem;
  position: relative;
}

.app-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  z-index: -1;
}

.app-header {
  padding: 1rem 1.5rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo {
  font-size: 2rem;
  width: 3rem;
  height: 3rem;
  background: linear-gradient(135deg, #60a5fa, #34d399);
  border-radius: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  animation: logoFloat 3s ease-in-out infinite;
}

.title {
  font-size: 1.75rem;
  font-weight: 600;
  color: white;
  margin: 0;
  text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.app-main {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 1.5rem;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

.board-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.board-container {
  padding: 1.5rem;
  display: flex;
  justify-content: center;
}

.game-controls {
  padding: 1rem;
  display: flex;
  gap: 0.75rem;
  justify-content: center;
}

.side-panel {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.panel-section {
  flex: 1;
  min-height: 200px;
}

.engine-panel {
  transition: all 0.3s ease;
  overflow: hidden;
}

.engine-panel:not(.expanded) {
  height: 0;
  min-height: 0;
  opacity: 0;
}

.app-footer {
  padding: 0.75rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1400px;
  margin: 0 auto;
  width: 100%;
}

.status-section {
  display: flex;
  gap: 2rem;
}

.status-item {
  display: flex;
  gap: 0.5rem;
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.875rem;
}

.status-label {
  opacity: 0.7;
}

.status-value {
  font-weight: 500;
}

.status-ready {
  color: #34d399;
}

.status-error {
  color: #f87171;
}

.connection-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #f87171;
  transition: background-color 0.3s ease;
}

.connection-indicator.online {
  background: #34d399;
}

.control-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 0.5rem;
  color: white;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  backdrop-filter: blur(10px);
}

.control-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.3);
  transform: translateY(-1px);
}

.control-btn:active {
  transform: translateY(0);
}

.control-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.control-btn.primary {
  background: linear-gradient(135deg, #60a5fa, #34d399);
  border-color: transparent;
}

.control-btn.primary:hover:not(:disabled) {
  background: linear-gradient(135deg, #3b82f6, #10b981);
}

.btn-icon {
  font-size: 1rem;
}

.btn-text {
  font-size: 0.8rem;
}

@keyframes logoFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-2px); }
}

/* Responsive design */
@media (max-width: 768px) {
  .app-main {
    grid-template-columns: 1fr;
    grid-template-rows: auto auto;
  }
  
  .side-panel {
    order: 2;
  }
  
  .header-content {
    padding: 0;
  }
  
  .title {
    font-size: 1.5rem;
  }
  
  .logo {
    width: 2.5rem;
    height: 2.5rem;
    font-size: 1.5rem;
  }
}

@media (max-width: 480px) {
  .app {
    padding: 0.5rem;
    gap: 0.75rem;
  }
  
  .game-controls {
    flex-wrap: wrap;
  }
  
  .control-btn {
    flex: 1;
    min-width: 0;
  }
}
</style>