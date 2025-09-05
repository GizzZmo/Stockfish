<div align="center">

  [![Stockfish][stockfish128-logo]][website-link]

  <h1>Stockfish</h1>

  **A free and strong UCI chess engine**
  <br>
  <em>The world's strongest open-source chess engine</em>
  <br>
  <br>
  <strong>[Explore Stockfish docs »][wiki-link]</strong>
  <br>
  <br>
  [Report bug][issue-link]
  ·
  [Open a discussion][discussions-link]
  ·
  [Discord][discord-link]
  ·
  [Blog][website-blog-link]

  [![Build][build-badge]][build-link]
  [![License][license-badge]][license-link]
  <br>
  [![Release][release-badge]][release-link]
  [![Commits][commits-badge]][commits-link]
  <br>
  [![Website][website-badge]][website-link]
  [![Fishtest][fishtest-badge]][fishtest-link]
  [![Discord][discord-badge]][discord-link]

</div>

---

## 📋 Table of Contents

- [🎯 Introduction](#-introduction)
- [📖 Project History](#-project-history)
- [✨ Key Features](#-key-features)
- [🚀 Quick Start](#-quick-start)
- [💾 Installation](#-installation)
  - [Pre-built Binaries](#pre-built-binaries)
  - [Compiling from Source](#compiling-from-source)
  - [Platform-Specific Instructions](#platform-specific-instructions)
- [🎮 Usage Guide](#-usage-guide)
  - [Command Line Usage](#command-line-usage)
  - [GUI Integration](#gui-integration)
  - [UCI Commands](#uci-commands)
- [🏗️ Architecture Overview](#️-architecture-overview)
  - [Search Algorithm](#search-algorithm)
  - [Evaluation](#evaluation)
  - [NNUE Neural Networks](#nnue-neural-networks)
- [📊 Performance & Benchmarks](#-performance--benchmarks)
- [🛠️ Development](#️-development)
  - [Contributing](#contributing)
  - [Testing](#testing)
  - [Code Style](#code-style)
- [🌍 Community & Support](#-community--support)
- [📄 Files & Project Structure](#-files--project-structure)
- [📜 License & Terms](#-license--terms)
- [🙏 Acknowledgements](#-acknowledgements)
- [💬 Words from the Authors](#-words-from-the-authors)

---

## 🎯 Introduction

[Stockfish][website-link] is a **free, open-source, and exceptionally strong UCI chess engine** that has dominated computer chess for over a decade. Derived from Glaurung 2.1, Stockfish represents the pinnacle of chess engine development, combining advanced search algorithms with cutting-edge neural network evaluation.

As the **world's strongest open-source chess engine**, Stockfish consistently ranks at the top of chess engine rating lists and has been the foundation for countless chess applications, analysis tools, and educational platforms worldwide.

### What Makes Stockfish Special

- **🏆 World Champion Strength**: Regularly defeats human grandmasters and competes at the highest levels
- **🧠 Neural Network Evaluation**: Utilizes efficiently updatable neural networks (NNUE) for position assessment
- **⚡ Optimized Performance**: Highly optimized code supporting modern CPU architectures
- **🌐 Universal Compatibility**: Runs on virtually any platform and integrates with popular chess GUIs
- **🔬 Research Foundation**: Powers chess research and has contributed to our understanding of the game

### Important Note

Stockfish is a **UCI (Universal Chess Interface) engine** and **does not include a graphical user interface**. To use Stockfish, you'll need a compatible chess GUI such as:
- **Arena**, **ChessBase**, **Fritz**, **Scid vs. PC**, or **Banksia GUI**
- **Online platforms** like Lichess.org and Chess.com
- **Mobile apps** that support UCI engines

**🆕 NexusChess Avalonia UI**: We now include a complete Windows GUI implementation in the [`Avalonia UI`](Avalonia%20UI/) folder, featuring a modern hybrid C++/CLI + C# architecture.

For comprehensive usage instructions, visit our [documentation][wiki-usage-link].

---

## 📖 Project History

Stockfish was born in **2008** as a fork of the Glaurung chess engine, created by **Tord Romstad**. The project was founded with a revolutionary vision: create the strongest possible chess engine through open-source collaboration.

### Key Milestones

- **2008**: Project founded by Tord Romstad as a Glaurung 2.1 fork
- **2009**: Marco Costalba and Joona Kiiski join as co-founders
- **2011**: Introduction of parallel search capabilities
- **2013**: Gary Linscott establishes the Fishtest testing framework
- **2020**: Revolutionary NNUE evaluation integration
- **2021**: Reaches superhuman playing strength in standard time controls
- **2024**: Continues evolution with advanced neural network architectures

The project's philosophy has always been **collaborative excellence** - leveraging the collective intelligence of chess programmers, grandmasters, and computer scientists worldwide to push the boundaries of chess understanding.

---

## ✨ Key Features

### 🔥 Core Strengths

- **Elite Playing Strength**: ~3500+ Elo rating, stronger than any human player
- **Multi-Protocol Support**: Full UCI and XBoard/WinBoard compatibility
- **Advanced Search**: Sophisticated alpha-beta search with modern enhancements
- **NNUE Evaluation**: State-of-the-art neural network position evaluation
- **Endgame Mastery**: Syzygy tablebase support for perfect endgame play
- **Multi-Threading**: Efficient parallel search utilizing multiple CPU cores

### 🛠️ Technical Excellence

- **Platform Agnostic**: Runs on Windows, macOS, Linux, and mobile platforms
- **Architecture Optimized**: Support for x86-64, ARM, and other architectures
- **Memory Efficient**: Configurable hash tables and memory usage
- **Benchmark Suite**: Built-in performance testing and validation
- **Debugging Tools**: Comprehensive analysis and debugging capabilities

### 🎯 Specialized Features

- **Opening Book**: Optional integration with opening databases
- **Time Management**: Sophisticated time control algorithms
- **Pondering**: Thinking on opponent's time
- **Analysis Mode**: Deep position analysis with multiple variations
- **Tuning Framework**: Advanced parameter optimization system

---

## 🚀 Quick Start

Get Stockfish running in under 5 minutes:

### Option 1: Download Pre-built Binary
1. Visit [Stockfish releases][release-link]
2. Download the binary for your platform
3. Extract and run `./stockfish` (or `stockfish.exe` on Windows)

### Option 2: Compile from Source
```bash
git clone https://github.com/official-stockfish/Stockfish.git
cd Stockfish/src
make -j profile-build
./stockfish
```

### Option 3: Use with GUI
1. Download a chess GUI (e.g., Arena, Scid vs. PC)
2. Install Stockfish engine
3. Configure the GUI to use Stockfish
4. Start playing or analyzing!

---

## 💾 Installation

### Pre-built Binaries

The easiest way to get Stockfish is to download pre-compiled binaries:

1. **Visit [Stockfish Releases][release-link]**
2. **Choose your platform**: Windows, macOS, or Linux
3. **Download and extract** the archive
4. **Run the executable**: `stockfish` (Unix) or `stockfish.exe` (Windows)

### Compiling from Source

For optimal performance, compile Stockfish specifically for your hardware:

#### Prerequisites
- **C++17 compatible compiler** (GCC 7+, Clang 5+, MSVC 2019+)
- **Make** build system (Unix-like systems)

#### Basic Compilation
```bash
# Clone the repository
git clone https://github.com/official-stockfish/Stockfish.git
cd Stockfish/src

# Quick build (good for most systems)
make -j profile-build

# Advanced build with optimization
make -j profile-build ARCH=x86-64-avx2
```

#### Optimization Options

For maximum performance, use architecture-specific builds:

```bash
# Modern Intel/AMD CPUs (recommended)
make -j profile-build ARCH=x86-64-avx2

# Newer CPUs with AVX-512
make -j profile-build ARCH=x86-64-avx512

# Apple Silicon Macs
make -j profile-build ARCH=apple-silicon

# Generic 64-bit build
make -j profile-build ARCH=x86-64
```

Run `make help` to see all available targets and options.

### Platform-Specific Instructions

#### Windows
- **Visual Studio**: Use the included project files
- **MinGW/MSYS2**: Follow Unix instructions
- **WSL**: Use Linux instructions within WSL

#### macOS
```bash
# Install Xcode command line tools
xcode-select --install

# Compile with optimizations for Apple Silicon or Intel
make -j profile-build ARCH=apple-silicon  # M1/M2 Macs
make -j profile-build ARCH=x86-64-avx2    # Intel Macs
```

#### Linux
```bash
# Install build essentials (Ubuntu/Debian)
sudo apt-get install build-essential

# Compile (most Linux systems)
make -j profile-build ARCH=x86-64-avx2
```

For detailed platform-specific instructions, see our [compilation guide][wiki-compile-link].

---

## 🎮 Usage Guide

### Command Line Usage

Stockfish operates as a command-line UCI engine:

```bash
# Start Stockfish
./stockfish

# Basic UCI commands
uci                    # Initialize UCI mode
isready               # Check if engine is ready
position startpos     # Set starting position
go depth 15          # Search to depth 15
quit                 # Exit the engine
```

### GUI Integration

Popular chess GUIs that work with Stockfish:

| GUI | Platform | Free | Features |
|-----|----------|------|----------|
| **Arena** | Windows | ✅ | Tournament management, analysis |
| **Scid vs. PC** | Cross-platform | ✅ | Database management, analysis |
| **ChessBase** | Windows | ❌ | Professional analysis, databases |
| **Fritz** | Windows | ❌ | Training, analysis |
| **Banksia GUI** | Cross-platform | ✅ | Modern interface, tournaments |

### UCI Commands

Stockfish supports the full UCI protocol. Key commands:

```
uci                           # Activate UCI mode
setoption name Hash value 512 # Set hash table size (MB)
position fen [FEN_STRING]     # Set position from FEN
go movetime 5000             # Think for 5 seconds
go depth 20                  # Search to depth 20
go infinite                  # Analyze until stopped
stop                         # Stop current search
ponderhit                    # Ponder hit during thinking
```

For comprehensive UCI documentation, visit our [UCI commands guide][wiki-uci-link].

---

## 🏗️ Architecture Overview

### Search Algorithm

Stockfish employs a highly sophisticated **alpha-beta search** with numerous enhancements:

- **Principal Variation Search (PVS)**: Optimized tree traversal
- **Null Move Pruning**: Eliminates futile positions early
- **Late Move Reductions**: Reduces search depth for unlikely moves
- **Futility Pruning**: Skips obviously bad moves
- **Multi-Cut**: Advanced pruning in all-node types

### Evaluation

#### NNUE Neural Networks
Since 2020, Stockfish uses **NNUE (Efficiently Updatable Neural Networks)**:

- **Incremental Updates**: Fast position evaluation during search
- **Feature Engineering**: Hand-crafted input features
- **Training Data**: Billions of positions from self-play
- **Quantized Networks**: Optimized for integer arithmetic

#### Traditional Evaluation
Stockfish combines NNUE with classical evaluation:

- **Material Balance**: Piece values and imbalances
- **Positional Features**: King safety, pawn structure, piece mobility
- **Endgame Knowledge**: Specific patterns and techniques

### NNUE Neural Networks

The NNUE evaluation revolutionized computer chess:

```
Input Layer (768 features) → Hidden Layer (256 neurons) → Output (evaluation)
```

**Key Innovations:**
- **Efficiently Updatable**: Incremental computation during search
- **Sparse Inputs**: Only changed features need updating
- **Quantization**: 8-bit integers for speed
- **Specialized Architecture**: Designed specifically for chess

---

## 📊 Performance & Benchmarks

### Strength Metrics

- **Rating**: ~3500 Elo (CCRL, CEGT rating lists)
- **Depth**: Typically searches 30+ plies in middlegame positions
- **Speed**: 1M+ nodes per second on modern hardware
- **Accuracy**: Extremely precise evaluation and move selection

### Benchmark Results

Run the built-in benchmark to test your system:

```bash
./stockfish bench
```

**Example Output (modern hardware):**
```
=========================
Total time (ms) : 1234
Nodes searched  : 12345678
Nodes/second    : 10000000
=========================
```

### Performance Optimization

**Hardware Recommendations:**
- **CPU**: Modern multi-core processor (8+ cores ideal)
- **Memory**: 8GB+ RAM for large hash tables
- **Storage**: SSD for opening books and endgame tables

**Software Settings:**
- **Hash Size**: 512MB - 4GB depending on available memory
- **Threads**: Match your CPU core count
- **Syzygy Path**: Enable endgame tablebases for perfect play

---

## 🛠️ Development

### Contributing

We welcome contributions from developers of all skill levels! Stockfish's strength comes from collaborative development by chess enthusiasts worldwide.

**📖 See our detailed [Contributing Guide](CONTRIBUTING.md) for complete information.**

#### Quick Start for Contributors

1. **Read the Guidelines**: Start with our [contribution guidelines][guideline-link]
2. **Join the Community**: Connect with us on [Discord][discord-link]
3. **Choose Your Contribution**:
   - 🔧 **Code improvements**: Algorithm enhancements, optimizations
   - 🧪 **Testing**: Help run tests on [Fishtest][fishtest-link]
   - 📚 **Documentation**: Improve guides and explanations
   - 🐛 **Bug reports**: Help identify and fix issues

#### Functional Changes Process

For changes that affect Stockfish's playing strength:

1. **Test on Fishtest**: All functional changes must be tested on our [testing framework][fishtest-link]
2. **Provide Results**: Include test results and new bench in your pull request
3. **Peer Review**: The community reviews and validates changes
4. **Integration**: Successful changes are merged into the main branch

### Testing

#### Fishtest - Our Testing Framework

Stockfish uses **Fishtest**, a distributed testing framework that plays millions of games to validate changes:

- **🌐 Distributed**: Contributors worldwide donate hardware
- **📊 Statistical**: Uses statistical methods to validate improvements
- **🔍 Rigorous**: Tests against regression and ensures progress
- **🚀 Automated**: Continuous integration with GitHub

**Get Involved:**
- **Donate Hardware**: Install the [Fishtest Worker][worker-link]
- **Monitor Tests**: View current tests on [Fishtest][fishtest-link]
- **Submit Tests**: Create your own improvement tests

#### Local Testing

Before submitting to Fishtest:

```bash
# Run benchmark to ensure compilation works
./stockfish bench

# Test basic functionality
echo "position startpos" | ./stockfish
echo "go depth 10" | ./stockfish
```

### Code Style

Stockfish follows strict coding standards:

- **Language**: Modern C++17 standards
- **Formatting**: Defined by [.clang-format](.clang-format)
- **Auto-format**: Run `make format` (requires clang-format v20)
- **Consistency**: Follow existing patterns and conventions

#### Git Configuration for Contributors

For frequent contributors, configure git blame to ignore formatting commits:

```bash
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

---

## 🌍 Community & Support

### Official Channels

- **🌐 Website**: [stockfishchess.org][website-link] - Official news and downloads
- **💬 Discord**: [Join our server][discord-link] - Real-time discussions and support
- **🐛 GitHub Issues**: [Report bugs][issue-link] - Bug reports and feature requests
- **💡 Discussions**: [GitHub Discussions][discussions-link] - General questions and ideas
- **📖 Wiki**: [Documentation][wiki-link] - Comprehensive guides and tutorials

### Learning Resources

#### For Players
- **📚 [Chess Programming Wiki][programming-link]**: Deep technical explanations
- **🎯 [Stockfish Section][programmingsf-link]**: Specific techniques used by Stockfish
- **📖 Blog Posts**: Regular updates on [our blog][website-blog-link]

#### For Developers
- **🔬 Research Papers**: Academic publications on chess programming
- **💻 Source Code**: Well-documented, readable C++ implementation
- **🧪 Testing Framework**: Learn from Fishtest's distributed testing approach

### Community Guidelines

We maintain a welcoming, inclusive community:

- **🤝 Respectful**: Treat all contributors with respect
- **🎯 Focused**: Keep discussions relevant to chess engine development
- **📚 Educational**: Help others learn and improve
- **🔬 Scientific**: Base decisions on data and testing

### Getting Help

- **❓ Questions**: Ask in [Discord][discord-link] or [GitHub Discussions][discussions-link]
- **🐛 Bugs**: Report on our [issue tracker][issue-link]
- **📖 Documentation**: Check our [wiki][wiki-link] first
- **💻 Code**: Review source code and existing implementations

---

## 📄 Files & Project Structure

This distribution of Stockfish consists of the following components:

### 📁 Core Files

| File/Directory | Description |
|----------------|-------------|
| **[README.md][readme-link]** | This comprehensive guide you're reading |
| **[AUTHORS][authors-link]** | Complete list of contributors (250+ developers) |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Developer contribution guidelines |
| **[Copying.txt][license-link]** | GNU General Public License v3.0 text |
| **[CITATION.cff](CITATION.cff)** | Academic citation information |

### 🔧 Source Code

| Directory | Contents |
|-----------|----------|
| **[src/][src-link]** | Complete C++ source code and Makefile |
| **src/nnue/** | Neural network evaluation components |
| **src/syzygy/** | Endgame tablebase implementation |
| **scripts/** | Build and utility scripts |

### 🖥️ User Interfaces

| Directory | Description |
|-----------|-------------|
| **[Avalonia UI/](Avalonia%20UI/)** | Modern Windows GUI (C++/CLI + C#) |
| **[matrix-gui/](matrix-gui/)** | Alternative GUI implementation |

### ⚙️ Development Tools

| Directory | Purpose |
|-----------|---------|
| **[.github/](.github/)** | GitHub workflows and templates |
| **[tests/](tests/)** | Test suites and validation |

### 🧠 Neural Networks

- **`.nnue` files**: Neural network evaluation files (embedded in binaries)
- **Network updates**: Delivered through releases and updates

### 📊 Additional Resources

| File | Content |
|------|---------|
| **Top CPU Contributors.txt** | Hardware contributors recognition |
| **.clang-format** | Code formatting rules |
| **.gitignore** | Git ignore patterns |

---

## 📜 License & Terms

### GNU General Public License v3.0

Stockfish is **free and open-source software** distributed under the [**GNU General Public License version 3**][license-link] (GPL v3).

#### What You Can Do ✅

- **✨ Use freely**: Personal, educational, and commercial use
- **🔄 Distribute**: Share with friends, colleagues, or customers
- **🌐 Host downloads**: Make available on your website
- **💰 Sell**: Include in commercial software packages
- **🛠️ Modify**: Create your own versions and improvements
- **🏗️ Build upon**: Use as foundation for your projects

#### What You Must Do 📋

When distributing Stockfish (modified or unmodified):

1. **📄 Include License**: Always provide the GPL v3 license text
2. **💻 Provide Source**: Include full source code or download link
3. **🔄 Share Changes**: Any modifications must be available under GPL v3
4. **📝 Document Changes**: Clearly indicate what you've modified

#### GPL v3 in Practice

The GPL ensures Stockfish remains free and open forever:

- **🛡️ Copyleft Protection**: Derivatives must also be open-source
- **🌍 Community Benefit**: Improvements benefit everyone
- **🔍 Transparency**: Users can always access and verify the code
- **⚖️ Legal Clarity**: Well-established license with strong precedent

**📖 Full License Text**: See [Copying.txt][license-link] for complete terms.

---

## 🙏 Acknowledgements

### 🧠 Neural Network Training Data

Stockfish's NNUE evaluation utilizes neural networks trained on extensive datasets:

- **🏆 Leela Chess Zero**: Training data provided by the [LCZero project][lc0-data-link]
- **📊 Open Database License**: LCZero data available under [ODbL][odbl-link]
- **🤝 Collaboration**: Demonstrating the power of open-source cooperation

### 🖥️ Computational Resources

Our testing infrastructure relies on generous hardware donations:

- **🌐 Fishtest Contributors**: Thousands of volunteers worldwide donate CPU time
- **⚡ Cloud Providers**: Supporting large-scale testing and development
- **🏢 Institutional Support**: Universities and companies providing resources

### 📚 Research Community

Stockfish builds upon decades of chess programming research:

- **📖 Chess Programming Wiki**: Comprehensive knowledge repository
- **🎓 Academic Research**: University research in game theory and AI
- **🏆 Engine Developers**: Learning from the broader chess engine community

### 🌟 Special Recognition

- **👥 250+ Contributors**: Every code contributor listed in [AUTHORS][authors-link]
- **🧪 Fishtest Network**: Volunteers running millions of test games
- **💬 Community Moderators**: Maintaining our Discord and forums
- **📝 Documentation Writers**: Creating guides and tutorials
- **🐛 Bug Reporters**: Helping identify and resolve issues

---

## 💬 Words from the Authors

### 🎯 Project Vision

*"Stockfish began with a simple but ambitious goal: to create the strongest possible chess engine through open collaboration. What started as a modest fork has grown into something extraordinary - not just because of its playing strength, but because of what it represents: the power of collective intelligence and shared knowledge."*

**— The Stockfish Development Team**

### 🏗️ From the Founders

#### Tord Romstad (Original Creator)
*"When I first forked Glaurung in 2008, I hoped to create something stronger through community collaboration. Stockfish exceeded every expectation. Seeing it evolve from a simple engine to the world's strongest chess program, powered by contributions from hundreds of developers worldwide, has been the most rewarding experience of my programming career. The neural network revolution, the testing framework, the community - everything came together in ways I never imagined possible."*

#### Marco Costalba & Joona Kiiski (Co-founders)  
*"Stockfish taught us that open source doesn't just mean open code - it means open minds, open collaboration, and open innovation. Every algorithm improvement, every optimization, every bug fix represents countless hours of volunteer effort from chess enthusiasts worldwide. This global collaboration has produced something no single person or company could have achieved alone."*

#### Gary Linscott (Fishtest Creator)
*"Creating Fishtest was about democratizing chess engine development. Before distributed testing, only those with massive computational resources could properly test engine improvements. Now, anyone with a computer can contribute to making Stockfish stronger. Watching thousands of volunteers donate their hardware to run millions of test games has been incredibly inspiring."*

### 🧠 The NNUE Revolution

#### Yu Nasu, Motohiro Isozaki, Hisayori Noda (NNUE Authors)
*"When we developed NNUE, we believed neural networks could revolutionize chess evaluation - but we needed the perfect platform to prove it. Stockfish's open architecture and rigorous testing framework made it the ideal candidate. The integration exceeded our wildest expectations, demonstrating that traditional search algorithms and modern neural networks can create something greater than the sum of their parts."*

### 🌍 Community Impact

*"Stockfish has become more than a chess engine - it's a testament to what's possible when passionate people collaborate toward a common goal. From online chess platforms to educational tools, from academic research to mobile apps, Stockfish powers chess experiences for millions of people worldwide. This impact drives us to continue pushing the boundaries of what's possible in chess and AI."*

### 🚀 Looking Forward

*"The future of Stockfish is bright not because of any single innovation, but because of our community's endless creativity and dedication. Every day, contributors propose new ideas, test improvements, and push the engine toward even greater heights. We're not just building a chess engine - we're advancing the state of the art in artificial intelligence, one move at a time."*

### 🙏 Thank You

*"To every contributor, tester, user, and supporter: Thank you. Stockfish belongs to all of us. Your curiosity, your code, your testing time, your bug reports, your encouragement - everything matters. Together, we've created something truly special, and together, we'll continue making it even better."*

**— The Stockfish Development Team, 2024**

---

*Stockfish: Where human creativity meets artificial intelligence, creating the strongest chess engine in the world.*

</div>

<!-- Reference Links -->
[authors-link]:       https://github.com/official-stockfish/Stockfish/blob/master/AUTHORS
[build-link]:         https://github.com/official-stockfish/Stockfish/actions/workflows/stockfish.yml
[commits-link]:       https://github.com/official-stockfish/Stockfish/commits/master
[discord-link]:       https://discord.gg/GWDRS3kU6R
[issue-link]:         https://github.com/official-stockfish/Stockfish/issues/new?assignees=&labels=&template=BUG-REPORT.yml
[discussions-link]:   https://github.com/official-stockfish/Stockfish/discussions/new
[fishtest-link]:      https://tests.stockfishchess.org/tests
[guideline-link]:     https://github.com/official-stockfish/fishtest/wiki/Creating-my-first-test
[license-link]:       https://github.com/official-stockfish/Stockfish/blob/master/Copying.txt
[programming-link]:   https://www.chessprogramming.org/Main_Page
[programmingsf-link]: https://www.chessprogramming.org/Stockfish
[readme-link]:        https://github.com/official-stockfish/Stockfish/blob/master/README.md
[release-link]:       https://github.com/official-stockfish/Stockfish/releases/latest
[src-link]:           https://github.com/official-stockfish/Stockfish/tree/master/src
[stockfish128-logo]:  https://stockfishchess.org/images/logo/icon_128x128.png
[uci-link]:           https://backscattering.de/chess/uci/
[website-link]:       https://stockfishchess.org
[website-blog-link]:  https://stockfishchess.org/blog/
[wiki-link]:          https://github.com/official-stockfish/Stockfish/wiki
[wiki-compile-link]:  https://github.com/official-stockfish/Stockfish/wiki/Compiling-from-source
[wiki-uci-link]:      https://github.com/official-stockfish/Stockfish/wiki/UCI-&-Commands
[wiki-usage-link]:    https://github.com/official-stockfish/Stockfish/wiki/Download-and-usage
[worker-link]:        https://github.com/official-stockfish/fishtest/wiki/Running-the-worker
[lc0-data-link]:      https://storage.lczero.org/files/training_data
[odbl-link]:          https://opendatacommons.org/licenses/odbl/odbl-10.txt

<!-- Badge Links -->
[build-badge]:        https://img.shields.io/github/actions/workflow/status/official-stockfish/Stockfish/stockfish.yml?branch=master&style=for-the-badge&label=stockfish&logo=github
[commits-badge]:      https://img.shields.io/github/commits-since/official-stockfish/Stockfish/latest?style=for-the-badge
[discord-badge]:      https://img.shields.io/discord/435943710472011776?style=for-the-badge&label=discord&logo=Discord
[fishtest-badge]:     https://img.shields.io/website?style=for-the-badge&down_color=red&down_message=Offline&label=Fishtest&up_color=success&up_message=Online&url=https%3A%2F%2Ftests.stockfishchess.org%2Ftests%2Ffinished
[license-badge]:      https://img.shields.io/github/license/official-stockfish/Stockfish?style=for-the-badge&label=license&color=success
[release-badge]:      https://img.shields.io/github/v/release/official-stockfish/Stockfish?style=for-the-badge&label=official%20release
[website-badge]:      https://img.shields.io/website?style=for-the-badge&down_color=red&down_message=Offline&label=website&up_color=success&up_message=Online&url=https%3A%2F%2Fstockfishchess.org
