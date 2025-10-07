# BijbelQuiz-MCP Server

Een MCP (Model Context Protocol) server die ALLEEN de web inhoud van `play.bijbelquiz.app` retourneert. Speciaal ontworpen voor directe toegang tot BijbelQuiz content zonder extra metadata - geeft puur de HTML inhoud terug voor het spelen van BijbelQuiz.

## ✨ Wat BijbelQuiz-MCP doet

- **🎯 ALLEEN BijbelQuiz**: Haalt uitsluitend inhoud op van play.bijbelquiz.app
- **📄 Pure HTML**: Retourneert ALLEEN de ruwe HTML inhoud zonder extra metadata
- **⚡ Directe Toegang**: Onmiddellijke toegang tot BijbelQuiz web content
- **🛡️ Betrouwbaar**: Solide foutafhandeling voor timeouts en netwerkproblemen
- **⏱️ Timeout Controle**: Instelbare timeout (standaard: 10 seconden)
- **🎮 Speelklaar**: Direct klaar voor gebruik met AI applicaties

## 🚀 Installatie & Setup

### 1. Dependencies Installeren
```bash
cd websites/bijbelquiz.app/mcp
npm install
```

### 2. Server Bouwen
```bash
npm run build
```

## 🎮 Gebruik

### Server Starten
```bash
npm start
```

Voor ontwikkeling met auto-restart:
```bash
npm run dev
```

## 🛠️ Beschikbare Tools

### `speel-bijbelquiz`

Start direct met spelen door de BijbelQuiz app inhoud op te halen.

**Parameters:**
- `timeout` (optioneel): Timeout in milliseconden (standaard: 10000)

**Voorbeeld gebruik:**
```json
{
  "timeout": 5000
}
```

**Response:**
- `content`: De volledige HTML inhoud van play.bijbelquiz.app (puur en alleen de web content)

## 💻 Ontwikkeling

### Project Structuur
```
websites/bijbelquiz.app/mcp/
├── src/
│   └── index.ts          # Hoofdserver implementatie
├── package.json          # Dependencies en scripts
├── tsconfig.json         # TypeScript configuratie
└── README.md            # Dit bestand
```

### 🎯 Belangrijkste Functies

1. **🎯 Puur BijbelQuiz**: ALLEEN toegang tot play.bijbelquiz.app - geen andere sites
2. **📄 Alleen HTML Content**: Retourneert uitsluitend de ruwe HTML inhoud zonder extra metadata
3. **⏱️ Timeout Beheer**: Gebruikt AbortController voor betrouwbaar timeout management
4. **🔍 Content Validatie**: Controleert of de juiste HTML inhoud wordt ontvangen
5. **🔧 Eenvoudige Response**: Direct de web content zonder poespas
6. **🎨 Geoptimaliseerde Headers**: Perfecte User-Agent en Referer voor BijbelQuiz toegang

## 🛡️ Beveiliging

- **🔒 Alleen BijbelQuiz**: Hardcoded toegang tot play.bijbelquiz.app alleen
- **⏱️ Timeout Bescherming**: Voorkomt hangende verbindingen
- **🏷️ Correcte Identificatie**: User-Agent identificeert als BijbelQuiz-SpelAssistent
- **🔗 Juiste Referentie**: Referer header naar bijbelquiz.app
- **💾 Geen Opslag**: Geen client-side state of cookies
- **🎯 BijbelQuiz Ecosystem**: Speciaal ontworpen voor BijbelQuiz integratie

## 🔧 Probleemoplossing

### Veelvoorkomende Problemen

1. **❌ Module Niet Gevonden**: Installeer dependencies met `npm install`
2. **❌ TypeScript Fouten**: Bouw project met `npm run build`
3. **⏱️ Timeout Problemen**: Verhoog timeout parameter als BijbelQuiz app traag reageert
4. **🚫 Toegangsproblemen**: Controleer of play.bijbelquiz.app bereikbaar is

### Testen
Test de server met MCP Inspector:
1. Start server: `npm start`
2. In andere terminal: `npx @modelcontextprotocol/inspector`
3. Verbind met server en test de `speel-bijbelquiz` tool

## 📜 Licentie

MIT License - zie LICENSE bestand voor details.

## 🎉 Welkom bij BijbelQuiz-MCP!

Deze server is ontworpen om AI applicaties directe toegang te geven tot BijbelQuiz web content. Het retourneert ALLEEN de pure HTML inhoud van play.bijbelquiz.app - niets meer, niets minder. Perfect voor naadloze integratie met AI systemen die direct met BijbelQuiz willen werken! 🎮⚡

**🎯 Eenvoudig principe:** `speel-bijbelquiz` → HTML content van play.bijbelquiz.app