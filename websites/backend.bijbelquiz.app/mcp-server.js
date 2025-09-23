const { z } = require('zod');
const fs = require('fs');
const path = require('path');
const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StreamableHTTPServerTransport } = require('@modelcontextprotocol/sdk/server/streamableHttp.js');

// Load questions from the existing file
const questionsPath = path.join(__dirname, 'api', 'questions-nl-sv.json');
let allQuestions = [];

try {
  const questionsData = fs.readFileSync(questionsPath, 'utf8');
  allQuestions = JSON.parse(questionsData);
  console.log(`Loaded ${allQuestions.length} questions`);
} catch (error) {
  console.error('Error loading questions:', error);
}

// Game state management
const gameSessions = new Map(); // sessionId -> { players, currentQuestion, scores, etc. }

// AI player implementation
class AIPlayer {
  constructor(name, difficulty = 3) {
    this.name = name;
    this.difficulty = difficulty; // 1-5 scale
    this.score = 0;
  }

  // Simulate AI answering a question
  answerQuestion(question) {
    // For multiple choice questions
    if (question.type === 'mc') {
      // Higher difficulty means better chance of correct answer
      const correctChance = 0.3 + (this.difficulty / 5) * 0.6; // 30-90% chance
      
      if (Math.random() < correctChance) {
        return question.juisteAntwoord;
      } else {
        // Pick a random wrong answer
        const wrongAnswers = question.fouteAntwoorden;
        return wrongAnswers[Math.floor(Math.random() * wrongAnswers.length)];
      }
    }
    
    // For true/false questions
    if (question.type === 'tf') {
      const correctChance = 0.4 + (this.difficulty / 5) * 0.5; // 40-90% chance
      
      if (Math.random() < correctChance) {
        return question.juisteAntwoord;
      } else {
        // Return the opposite for true/false
        return question.juisteAntwoord === "Waar" ? "Niet waar" : "Waar";
      }
    }
    
    // For fill-in-the-blank questions
    if (question.type === 'fitb') {
      const correctChance = 0.2 + (this.difficulty / 5) * 0.5; // 20-70% chance
      
      if (Math.random() < correctChance) {
        return question.juisteAntwoord;
      } else {
        // Pick a random wrong answer
        const wrongAnswers = question.fouteAntwoorden;
        return wrongAnswers[Math.floor(Math.random() * wrongAnswers.length)];
      }
    }
    
    // Default fallback
    return question.juisteAntwoord;
  }
}

// Game session class
class GameSession {
  constructor(sessionId, playerNames = []) {
    this.sessionId = sessionId;
    this.players = [];
    this.aiPlayers = [];
    this.currentQuestionIndex = 0;
    this.questions = [];
    this.scores = {};
    this.gameState = 'waiting'; // waiting, active, finished
    this.currentQuestion = null;
    this.playerAnswers = {}; // playerId -> answer
    this.questionStartTime = null;
    this.timeLimit = 30000; // 30 seconds per question
    
    // Add human players
    for (const playerName of playerNames) {
      this.players.push(playerName);
      this.scores[playerName] = 0;
    }
    
    // Add AI players (3 by default)
    for (let i = 1; i <= 3; i++) {
      const aiPlayer = new AIPlayer(`AI-${i}`, Math.floor(Math.random() * 5) + 1);
      this.aiPlayers.push(aiPlayer);
      this.scores[aiPlayer.name] = 0;
    }
    
    // Select 10 random questions for this game
    this.questions = this.selectRandomQuestions(10);
  }
  
  selectRandomQuestions(count) {
    // Filter for supported question types
    const supportedQuestions = allQuestions.filter(q => 
      q.type === 'mc' || q.type === 'tf' || q.type === 'fitb'
    );
    
    // Shuffle and select
    const shuffled = [...supportedQuestions].sort(() => 0.5 - Math.random());
    return shuffled.slice(0, count);
  }
  
  startGame() {
    if (this.questions.length === 0) {
      throw new Error('No questions available for this game');
    }
    
    this.gameState = 'active';
    this.currentQuestionIndex = 0;
    this.nextQuestion();
  }
  
  nextQuestion() {
    if (this.currentQuestionIndex >= this.questions.length) {
      this.endGame();
      return;
    }
    
    this.currentQuestion = this.questions[this.currentQuestionIndex];
    this.playerAnswers = {};
    this.questionStartTime = Date.now();
    
    // Get AI answers
    for (const aiPlayer of this.aiPlayers) {
      setTimeout(() => {
        const answer = aiPlayer.answerQuestion(this.currentQuestion);
        this.submitAnswer(aiPlayer.name, answer);
      }, Math.random() * 5000); // AI answers within 0-5 seconds
    }
    
    this.currentQuestionIndex++;
  }
  
  submitAnswer(playerName, answer) {
    if (this.gameState !== 'active' || !this.currentQuestion) {
      return false;
    }
    
    // Store the answer
    this.playerAnswers[playerName] = answer;
    
    // Check if answer is correct
    const isCorrect = answer === this.currentQuestion.juisteAntwoord;
    
    // Update score (1 point for correct answer)
    if (isCorrect) {
      this.scores[playerName] = (this.scores[playerName] || 0) + 1;
    }
    
    // Check if all players have answered
    const totalPlayers = this.players.length + this.aiPlayers.length;
    if (Object.keys(this.playerAnswers).length >= totalPlayers) {
      // Move to next question after a short delay
      setTimeout(() => {
        this.nextQuestion();
      }, 3000);
    }
    
    return true;
  }
  
  endGame() {
    this.gameState = 'finished';
    this.currentQuestion = null;
  }
  
  getGameStatus() {
    return {
      sessionId: this.sessionId,
      gameState: this.gameState,
      currentQuestion: this.currentQuestion,
      scores: this.scores,
      playerAnswers: this.playerAnswers,
      totalQuestions: this.questions.length,
      currentQuestionNumber: this.currentQuestionIndex,
      players: this.players,
      aiPlayers: this.aiPlayers.map(ai => ai.name)
    };
  }
}

// Create MCP server
const mcpServer = new McpServer({
  name: "BijbelQuiz MCP Server",
  version: "1.0.0"
});

// Register tools
mcpServer.registerTool("start_new_game",
  {
    description: "Start a new game of BijbelQuiz with AI opponents",
    inputSchema: {
      playerName: z.string().describe("Name of the human player"),
      sessionId: z.string().describe("Unique session ID for the game")
    }
  },
  async ({ playerName, sessionId }) => {
    // Create new game session
    const gameSession = new GameSession(sessionId, [playerName]);
    gameSessions.set(sessionId, gameSession);
    
    // Start the game
    gameSession.startGame();
    
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          result: "Game started successfully",
          sessionId: sessionId,
          gameStatus: gameSession.getGameStatus()
        })
      }]
    };
  }
);

mcpServer.registerTool("submit_answer",
  {
    description: "Submit an answer to the current question",
    inputSchema: {
      sessionId: z.string().describe("Game session ID"),
      playerName: z.string().describe("Player name"),
      answer: z.string().describe("Player's answer")
    }
  },
  async ({ sessionId, playerName, answer }) => {
    const gameSession = gameSessions.get(sessionId);
    if (!gameSession) {
      return {
        content: [{
          type: "text",
          text: JSON.stringify({ error: "Game session not found" })
        }]
      };
    }
    
    const success = gameSession.submitAnswer(playerName, answer);
    
    if (success) {
      return {
        content: [{
          type: "text",
          text: JSON.stringify({
            result: "Answer submitted successfully",
            gameStatus: gameSession.getGameStatus()
          })
        }]
      };
    } else {
      return {
        content: [{
          type: "text",
          text: JSON.stringify({ error: "Failed to submit answer" })
        }]
      };
    }
  }
);

mcpServer.registerTool("get_game_status",
  {
    description: "Get the current status of a game session",
    inputSchema: {
      sessionId: z.string().describe("Game session ID")
    }
  },
  async ({ sessionId }) => {
    const gameSession = gameSessions.get(sessionId);
    if (!gameSession) {
      return {
        content: [{
          type: "text",
          text: JSON.stringify({ error: "Game session not found" })
        }]
      };
    }
    
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          gameStatus: gameSession.getGameStatus()
        })
      }]
    };
  }
);

mcpServer.registerTool("get_current_question",
  {
    description: "Get the current question in a game session",
    inputSchema: {
      sessionId: z.string().describe("Game session ID")
    }
  },
  async ({ sessionId }) => {
    const gameSession = gameSessions.get(sessionId);
    if (!gameSession) {
      return {
        content: [{
          type: "text",
          text: JSON.stringify({ error: "Game session not found" })
        }]
      };
    }
    
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          currentQuestion: gameSession.currentQuestion,
          timeLimit: gameSession.timeLimit,
          questionStartTime: gameSession.questionStartTime
        })
      }]
    };
  }
);

mcpServer.registerTool("list_questions",
  {
    description: "List available questions for the quiz",
    inputSchema: {
      limit: z.number().optional().describe("Number of questions to return").default(10),
      type: z.enum(["mc", "tf", "fitb"]).optional().describe("Filter by question type"),
      difficulty: z.number().min(1).max(5).optional().describe("Filter by difficulty level (1-5)")
    }
  },
  async ({ limit = 10, type, difficulty }) => {
    let filteredQuestions = allQuestions;
    
    // Filter by type if specified
    if (type) {
      filteredQuestions = allQuestions.filter(q => q.type === type);
    }
    
    // Filter by difficulty if specified
    if (difficulty) {
      filteredQuestions = filteredQuestions.filter(q => q.moeilijkheidsgraad === difficulty);
    }
    
    // Return a sample of questions
    const sample = filteredQuestions
      .sort(() => 0.5 - Math.random())
      .slice(0, limit);
    
    return {
      content: [{
        type: "text",
        text: JSON.stringify({
          questions: sample.map(q => ({
            question: q.vraag,
            type: q.type,
            difficulty: q.moeilijkheidsgraad,
            categories: q.categories,
            correctAnswer: q.juisteAntwoord,
            wrongAnswers: q.fouteAntwoorden,
            biblicalReference: q.biblicalReference
          }))
        })
      }]
    };
  }
);

mcpServer.registerTool("get_random_question",
  {
    description: "Get a single random question from the database",
    inputSchema: {
      type: z.enum(["mc", "tf", "fitb"]).optional().describe("Filter by question type"),
      difficulty: z.number().min(1).max(5).optional().describe("Filter by difficulty level (1-5)")
    }
  },
  async ({ type, difficulty }) => {
    let filteredQuestions = allQuestions;
    
    // Filter by type if specified
    if (type) {
      filteredQuestions = allQuestions.filter(q => q.type === type);
    }
    
    // Filter by difficulty if specified
    if (difficulty) {
      filteredQuestions = filteredQuestions.filter(q => q.moeilijkheidsgraad === difficulty);
    }
    
    // Return a random question
    if (filteredQuestions.length > 0) {
      const randomQuestion = filteredQuestions[Math.floor(Math.random() * filteredQuestions.length)];
      
      return {
        content: [{
          type: "text",
          text: JSON.stringify({
            question: randomQuestion.vraag,
            type: randomQuestion.type,
            difficulty: randomQuestion.moeilijkheidsgraad,
            categories: randomQuestion.categories,
            correctAnswer: randomQuestion.juisteAntwoord,
            wrongAnswers: randomQuestion.fouteAntwoorden,
            biblicalReference: randomQuestion.biblicalReference
          })
        }]
      };
    } else {
      return {
        content: [{
          type: "text",
          text: JSON.stringify({ error: "No questions found matching the criteria" })
        }]
      };
    }
  }
);

console.log('BijbelQuiz MCP Server initialized');

module.exports = { mcpServer, gameSessions, GameSession, AIPlayer };