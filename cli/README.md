# BijbelQuiz API CLI

A command-line interface for interacting with the BijbelQuiz local API.

**Note: This is a proof-of-concept (PoC) utility for testing and demonstrating the BijbelQuiz API functionality. It is not intended for production use.**

## Installation

1. Create a virtual environment and install Python dependencies:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

2. Make the script executable:
```bash
chmod +x bijbelquiz_cli.py
```

## Usage

All commands require an API key. You can get this from the BijbelQuiz app settings.

### Basic Syntax

```bash
# Activate virtual environment first
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Then run the CLI
python bijbelquiz_cli.py --api-key YOUR_API_KEY COMMAND [OPTIONS]
```

### Available Commands

#### Health Check
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY health
```

#### Get Questions
```bash
# Get 10 random questions
python bijbelquiz_cli.py --api-key YOUR_API_KEY questions

# Get questions from Genesis category
python bijbelquiz_cli.py --api-key YOUR_API_KEY questions --category Genesis

# Get 5 hard questions
python bijbelquiz_cli.py --api-key YOUR_API_KEY questions --limit 5 --difficulty 4
```

#### Get User Progress
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY progress
```

#### Get Game Statistics
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY stats
```

#### Get App Settings
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY settings
```

#### Star Management

##### Get Star Balance
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY stars balance
```

##### Add Stars
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY stars add 10 "Quiz completed" --lesson-id lesson_1
```

##### Spend Stars
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY stars spend 5 "Skip question"
```

##### Get Star Transactions
```bash
# Get last 20 transactions
python bijbelquiz_cli.py --api-key YOUR_API_KEY stars transactions --limit 20

# Get only earned transactions
python bijbelquiz_cli.py --api-key YOUR_API_KEY stars transactions --type earned
```

##### Get Star Statistics
```bash
python bijbelquiz_cli.py --api-key YOUR_API_KEY stars stats
```

### Custom API URL

If your API is running on a different port or host:
```bash
python bijbelquiz_cli.py --url http://localhost:8080/v1 --api-key YOUR_API_KEY health
```

## Examples

### Check API Health
```bash
$ python bijbelquiz_cli.py --api-key bq_abc123 health
{
  "status": "healthy",
  "timestamp": "2025-10-20T16:45:49.539Z",
  "service": "BijbelQuiz API",
  "version": "v1",
  "uptime": "running"
}
```

### Get Questions
```bash
$ python bijbelquiz_cli.py --api-key bq_abc123 questions --category Genesis --limit 3
{
  "questions": [
    {
      "question": "Wie bouwde de ark?",
      "correctAnswer": "Noach",
      "incorrectAnswers": ["Abraham", "Mozes", "David"],
      "difficulty": 2,
      "type": "mc",
      "categories": ["Genesis"],
      "biblicalReference": "Genesis 6",
      "allOptions": ["Noach", "Abraham", "Mozes", "David"],
      "correctAnswerIndex": 0
    }
  ],
  "count": 1,
  "category": "Genesis",
  "difficulty": null,
  "timestamp": "2025-10-20T16:45:49.539Z",
  "processing_time_ms": 45
}
```

### Add Stars
```bash
$ python bijbelquiz_cli.py --api-key bq_abc123 stars add 10 "Daily bonus"
{
  "success": true,
  "balance": 1260,
  "amount_added": 10,
  "reason": "Daily bonus",
  "timestamp": "2025-10-20T16:45:49.539Z",
  "processing_time_ms": 15
}
```

## Error Handling

The CLI provides clear error messages for common issues:

- **Connection errors**: Check if the API server is running
- **Authentication errors**: Verify your API key
- **Rate limiting**: Wait before retrying (check Retry-After header)
- **Invalid parameters**: Check command syntax and parameter values

## Requirements

- Python 3.6+
- Virtual environment (recommended)
- requests library (installed via requirements.txt)

## Notes

This is a proof-of-concept CLI utility designed for:
- Testing API endpoints during development
- Demonstrating API functionality
- Quick API interaction for debugging

For production use, consider:
- Better error handling
- Configuration file support
- Interactive mode
- Output formatting options
- Authentication token management