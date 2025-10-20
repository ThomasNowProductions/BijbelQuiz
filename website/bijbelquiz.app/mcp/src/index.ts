import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

// Create MCP server instance
const server = new McpServer({
  name: "bijbelquiz-mcp",
  version: "1.0.0",
});

  // Tool om BijbelQuiz te spelen
  server.registerTool(
    "speel-bijbelquiz",
    {
      title: "Speel BijbelQuiz",
      description: "Haalt de BijbelQuiz app inhoud op om direct te kunnen spelen",
      inputSchema: {
        type: "object",
        properties: {
          timeout: {
            type: "number",
            description: "Timeout voor de aanvraag in milliseconden (standaard: 10000)",
          },
        },
      } as any,
    },
  async (request, extra) => {
    const { timeout = 10000 } = request.params || {};
    const url = "https://play.bijbelquiz.app";

    try {
      console.error(`Bezig met ophalen van BijbelQuiz app inhoud: ${url}`);

      // Create AbortController voor timeout afhandeling
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      try {
        // HTML inhoud ophalen met timeout
        const response = await fetch(url, {
          signal: controller.signal,
          headers: {
            "User-Agent": "BijbelQuiz-SpelAssistent/1.0.0",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "nl-NL,nl;q=0.9,en;q=0.8",
            "Accept-Encoding": "identity", // Compressie problemen voorkomen
            "Cache-Control": "no-cache",
            "Referer": "https://bijbelquiz.app",
          },
        });

        clearTimeout(timeoutId);

        // Controleer of de response succesvol is
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        // Controleer content type
        const contentType = response.headers.get("content-type");
        if (!contentType?.includes("text/html")) {
          console.warn(`Waarschuwing: Content-Type is ${contentType}, geen text/html`);
        }

        // HTML inhoud ophalen
        const htmlContent = await response.text();

        console.error(`Succesvol ${htmlContent.length} karakters aan HTML inhoud opgehaald van BijbelQuiz`);

        return {
          content: [
            {
              type: "text",
              text: htmlContent,
            },
          ],
        };
      } catch (fetchError) {
        clearTimeout(timeoutId);

        if (fetchError instanceof Error) {
          if (fetchError.name === "AbortError") {
            throw new Error(`Aanvraag timeout na ${timeout}ms`);
          }
          throw fetchError;
        }
        throw new Error("Onbekende ophaalfout opgetreden");
      }
    } catch (error) {
      console.error(`Fout bij ophalen van BijbelQuiz inhoud:`, error);

      return {
        content: [
          {
            type: "text",
            text: `Fout bij ophalen van BijbelQuiz app inhoud: ${error instanceof Error ? error.message : "Onbekende fout"}`,
          },
        ],
      };
    }
  }
);

// Start de server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("BijbelQuiz SpelAssistent MCP server gestart - klaar om te spelen!");
}

// Handel proces beëindiging af
process.on("SIGINT", async () => {
  console.error("MCP server wordt afgesloten...");
  process.exit(0);
});

main().catch((error) => {
  console.error("Kon MCP server niet starten:", error);
  process.exit(1);
});