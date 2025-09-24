# NeuralChess PWA - Modern Progressive Web App for Stockfish

A high-performance, secure, and aesthetically modern Progressive Web App (PWA) interface for the Stockfish chess engine, featuring glassmorphism design, WebAssembly integration, and advanced security measures.

## 🚀 Features

### Performance
- **Vue.js 3 with Composition API**: Optimal reactivity and performance
- **WebAssembly Integration**: Fast, secure engine communication
- **Web Workers**: Non-blocking engine operations
- **Service Worker**: Offline capability and caching
- **Virtual DOM**: Efficient rendering updates
- **Lazy Loading**: Components loaded on demand

### Aesthetics  
- **Glassmorphism Design**: Modern translucent UI elements
- **Smooth Animations**: CSS3 transforms and transitions
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Dark/Light Themes**: User-configurable themes
- **Micro-interactions**: Delightful user feedback
- **Custom Chess Pieces**: SVG-based scalable pieces

### Security
- **Content Security Policy**: Strict CSP headers for XSS protection
- **Secure WebSocket**: Encrypted engine communication
- **Input Validation**: Comprehensive move and command validation
- **Process Isolation**: Sandboxed engine execution
- **HTTPS Enforcement**: Secure connections only
- **No Eval Usage**: Safe code execution practices

## 🛠 Technology Stack

- **Frontend Framework**: Vue.js 3 with TypeScript
- **CSS Framework**: Custom CSS with CSS Grid and Flexbox
- **Chess Logic**: chess.js for game rules and validation
- **Engine Communication**: WebAssembly + Web Workers
- **PWA Features**: Service Worker, Web App Manifest
- **Build Tool**: Vite for fast development and optimized builds
- **Testing**: Vitest for unit tests

## 📁 Project Structure

```
neuralchess-pwa/
├── public/
│   ├── manifest.json           # PWA manifest
│   ├── sw.js                   # Service worker
│   └── icons/                  # PWA icons
├── src/
│   ├── components/
│   │   ├── ChessBoard.vue      # Interactive chess board
│   │   ├── EnginePanel.vue     # Engine analysis display
│   │   ├── GameHistory.vue     # Move history
│   │   └── ThemeSelector.vue   # Theme controls
│   ├── composables/
│   │   ├── useEngine.js        # Engine communication logic
│   │   ├── useChessGame.js     # Game state management
│   │   └── useTheme.js         # Theme management
│   ├── workers/
│   │   └── stockfish.worker.js # WebAssembly engine worker
│   ├── styles/
│   │   ├── glassmorphism.css   # Modern glassmorphism styles
│   │   ├── animations.css      # Smooth animations
│   │   └── responsive.css      # Responsive design
│   ├── utils/
│   │   ├── security.js         # Security utilities
│   │   └── validation.js       # Input validation
│   ├── App.vue                 # Main application component
│   └── main.js                 # Application entry point
├── wasm/
│   └── stockfish.wasm          # WebAssembly engine build
├── package.json                # Dependencies and scripts
├── vite.config.js             # Vite configuration
└── README.md                  # This file
```

## 🔧 Installation

### Prerequisites
- Node.js 18+ and npm
- Modern web browser with WebAssembly support

### Setup
```bash
cd neuralchess-pwa
npm install
```

### Development
```bash
npm run dev
```

### Production Build
```bash
npm run build
npm run preview
```

### Building Stockfish WebAssembly
```bash
npm run build:wasm
```

## 🎨 Customization

### Themes
Edit `src/styles/glassmorphism.css` to customize the glassmorphism theme:
- Glass effects: Adjust backdrop-filter values
- Colors: Modify CSS custom properties
- Animations: Customize transition timings

### Engine Settings
Modify engine parameters in `src/composables/useEngine.js`:
- Search depth and time controls
- UCI option configurations
- Analysis features

## 🔒 Security Features

### Content Security Policy
- Strict CSP prevents XSS attacks
- No inline scripts or styles
- Restricted external resource loading

### Engine Security
- WebAssembly sandboxing
- Process isolation
- Input sanitization
- Command validation

## 🚀 Performance Optimizations

### Code Splitting
- Route-based lazy loading
- Component-level code splitting
- Dynamic imports for heavy dependencies

### Caching Strategy
- Service worker caching
- Static asset caching
- Engine response caching

### Bundle Optimization
- Tree shaking for unused code
- Minification and compression
- WebP image optimization

## 🧪 Testing

```bash
# Unit tests
npm run test

# End-to-end tests
npm run test:e2e

# Coverage report
npm run test:coverage
```

## 📱 PWA Features

- **Offline Play**: Works without internet connection
- **Install Prompt**: Add to home screen
- **Push Notifications**: Game reminders (optional)
- **Background Sync**: Sync games when online
- **Responsive**: Works on all device sizes

## 🔧 Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

*WebAssembly and Service Worker support required*

## 📈 Performance Metrics

Target performance goals:
- First Contentful Paint: < 1.5s
- Largest Contentful Paint: < 2.5s
- Cumulative Layout Shift: < 0.1
- First Input Delay: < 100ms

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## 📄 License

This project inherits the GPL v3 license from Stockfish.

## 🙏 Acknowledgments

- Stockfish team for the incredible chess engine
- Vue.js community for the excellent framework
- WebAssembly working group for making this possible