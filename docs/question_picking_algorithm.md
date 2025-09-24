# Question Picking Algorithm Documentation

## TL;DR: Quick Overview

The Progressive Question Up-selection (PQU) algorithm works by:
1. **Adapting difficulty** based on user performance (correct/incorrect answers, streaks, time taken)
2. **Selecting questions** within ±1 difficulty level of the target difficulty
3. **Avoiding repetition** by tracking recently used questions (last 50 questions)
4. **Mapping internal difficulty** [0..2] to JSON levels [1..5] (0.0→1, 1.0→3, 2.0→5)
5. **Applying dampening** for long sessions to prevent extreme difficulty swings
6. **Randomly selecting** from eligible questions to ensure variety

The system balances challenge and engagement by increasing difficulty when users perform well and decreasing it when they struggle, while preventing question repetition and maintaining variety.

## Overview

The BijbelQuiz application uses a sophisticated question picking algorithm called the Progressive Question Up-selection (PQU) algorithm. This algorithm dynamically adjusts question difficulty based on player performance to maintain an optimal challenge level and prevent boredom or frustration.

## Key Components

### Progressive Question Selector (`ProgressiveQuestionSelector`)

Located in `app/lib/services/progressive_question_selector.dart`, this service manages the PQU algorithm and provides the core functionality for question selection and difficulty adjustment.

## How the PQU Algorithm Works

### 1. Difficulty Management System

The algorithm uses a normalized internal difficulty scale of [0..2] which maps to the JSON difficulty levels [1..5]:

- Internal difficulty 0.0 → JSON level 1 (easiest)
- Internal difficulty 1.0 → JSON level 3 (medium)
- Internal difficulty 2.0 → JSON level 5 (hardest)

The mapping formula is: `level = 1 + (normalized_difficulty * 2)`

### 2. Question Selection Process

The `pickNextQuestion()` method follows these phases:

#### Phase 1: Calculate Target Difficulty
- Analyzes recent performance (correct/incorrect ratio)
- Adjusts difficulty based on performance thresholds:
  - High performance (>90% correct): Increase difficulty significantly
  - Good performance (75-90% correct): Increase difficulty moderately
  - Poor performance (<30% correct): Decrease difficulty significantly
  - Below average performance (30-50% correct): Decrease difficulty moderately

#### Phase 2: Apply Dampening for Long Sessions
- Prevents extreme difficulty swings after many questions
- Reduces adjustment magnitude as session length increases (after 30+ questions)

#### Phase 3: Constrain Difficulty Range
- Ensures difficulty stays within bounds [0.0, 2.0]

#### Phase 4: Map to JSON Difficulty Levels
- Converts normalized difficulty to JSON levels [1..5]

#### Phase 5: Filter Available Questions
- Selects questions not yet used in current session
- Prioritizes questions within ±1 difficulty level of target
- Falls back to exact difficulty matches
- Final fallback to any available question

#### Phase 6: Apply Anti-Repetition Filter
- Prevents showing recently used questions (within last 50 questions)
- Clears recent list if no eligible questions remain

#### Phase 7: Random Selection
- Randomly selects from eligible questions to ensure variety

#### Phase 8: Update Usage Tracking
- Adds selected question to used and recently used lists
- Maintains FIFO queue for recently used questions (limit 50)

### 3. Dynamic Difficulty Adjustment

The `calculateNextDifficulty()` method considers multiple factors:

#### Immediate Performance Factors
- **Answer correctness**: Primary factor for difficulty adjustment
  - Correct answer: +0.08 difficulty
  - Incorrect answer: -0.10 difficulty
- **Streak bonus**: Rewards sustained performance
  - Every 3 consecutive correct answers adds +0.05 difficulty
- **Speed bonus/malus**: Considers time remaining when answering
  - Quick correct answers (time > 10s): +0.05 difficulty
  - Slow incorrect answers (time < 5s): -0.03 difficulty
  - Extra penalty for breaking a streak with incorrect answer: -0.05

#### Long-term Performance Factors
- **Session performance ratio**: Adjusts based on overall session performance
  - Consistently high performance (>85% correct): +0.05 difficulty
  - Consistently low performance (<50% correct): -0.05 difficulty

#### Anti-Stagnation Randomization
- Adds small random variation to prevent getting stuck at same difficulty
- Random adjustment of ±0.075 to explore different difficulty levels

### 4. Question Pool Management

- **Used Questions Tracking**: Prevents repetition within a session
- **Recently Used Queue**: Tracks last 50 questions to avoid immediate repetition
- **Pool Exhaustion Handling**: When all questions are used, reshuffles and repopulates
- **Background Loading**: Automatically loads more questions when running low

### 5. Session Management

The algorithm provides methods for different scenarios:

- `resetQuestionPool()`: Resets for new game or language change
- `resetForNewGame()`: Resets for new game session while preserving question pool
- Session-aware difficulty management that considers total questions answered

## Usage in Quiz Screen

The `QuizScreen` uses the Progressive Question Selector in these ways:

1. **Initialization**: Sets up the selector with question cache service
2. **Question Fetching**: Calls `pickNextQuestion()` to get next question
3. **Difficulty Updates**: Calls `calculateNextDifficulty()` after each answer
4. **State Management**: Maintains mounted state and setState callbacks

## Benefits

1. **Adaptive Learning**: Adjusts difficulty to match user ability
2. **Engagement**: Maintains optimal challenge level to prevent boredom/frustration
3. **Variety**: Ensures diverse questions and prevents repetition
4. **Performance**: Optimized to run efficiently even on low-end devices
5. **Scalability**: Works with large question pools and continuous gameplay

## Performance Optimizations

- Efficient filtering algorithms to handle large question sets
- Memory-conscious tracking of used questions
- Background loading to maintain performance
- Dampening mechanisms to prevent extreme difficulty swings