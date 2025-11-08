#!/usr/bin/env python3
"""
BijbelQuiz API CLI - Proof of Concept

A command-line interface for interacting with the BijbelQuiz local API.
"""

import argparse
import json
import sys
from typing import Optional

import requests


class BijbelQuizAPI:
    """Client for the BijbelQuiz local API."""

    def __init__(self, base_url: str = "http://localhost:7777/v1", api_key: Optional[str] = None):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.session = requests.Session()
        if api_key:
            self.session.headers.update({"X-API-Key": api_key})

    def _get(self, endpoint: str, params: Optional[dict] = None) -> dict:
        """Make a GET request to the API."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        try:
            response = self.session.get(url, params=params)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}", file=sys.stderr)
            if hasattr(e, 'response') and e.response:
                try:
                    error_data = e.response.json()
                    print(f"API Error: {error_data.get('error', 'Unknown error')}", file=sys.stderr)
                    print(f"Message: {error_data.get('message', '')}", file=sys.stderr)
                except:
                    print(f"HTTP {e.response.status_code}: {e.response.text}", file=sys.stderr)
            sys.exit(1)

    def _post(self, endpoint: str, data: dict) -> dict:
        """Make a POST request to the API."""
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        try:
            response = self.session.post(url, json=data)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}", file=sys.stderr)
            if hasattr(e, 'response') and e.response:
                try:
                    error_data = e.response.json()
                    print(f"API Error: {error_data.get('error', 'Unknown error')}", file=sys.stderr)
                    print(f"Message: {error_data.get('message', '')}", file=sys.stderr)
                except:
                    print(f"HTTP {e.response.status_code}: {e.response.text}", file=sys.stderr)
            sys.exit(1)

    def health(self) -> dict:
        """Check API health."""
        return self._get("health")

    def get_questions(self, category: Optional[str] = None, limit: int = 10, difficulty: Optional[int] = None) -> dict:
        """Get quiz questions."""
        params = {"limit": limit}
        if category:
            params["category"] = category
        if difficulty:
            params["difficulty"] = difficulty
        return self._get("questions", params)

    def get_progress(self) -> dict:
        """Get user progress."""
        return self._get("progress")

    def get_stats(self) -> dict:
        """Get game statistics."""
        return self._get("stats")

    def get_settings(self) -> dict:
        """Get app settings."""
        return self._get("settings")

    def get_star_balance(self) -> dict:
        """Get star balance."""
        return self._get("stars/balance")

    def add_stars(self, amount: int, reason: str, lesson_id: Optional[str] = None) -> dict:
        """Add stars to balance."""
        data = {"amount": amount, "reason": reason}
        if lesson_id:
            data["lessonId"] = lesson_id
        return self._post("stars/add", data)

    def spend_stars(self, amount: int, reason: str, lesson_id: Optional[str] = None) -> dict:
        """Spend stars from balance."""
        data = {"amount": amount, "reason": reason}
        if lesson_id:
            data["lessonId"] = lesson_id
        return self._post("stars/spend", data)

    def get_star_transactions(self, limit: int = 50, type_filter: Optional[str] = None, lesson_id: Optional[str] = None) -> dict:
        """Get star transactions."""
        params = {"limit": limit}
        if type_filter:
            params["type"] = type_filter
        if lesson_id:
            params["lessonId"] = lesson_id
        return self._get("stars/transactions", params)

    def get_star_stats(self) -> dict:
        """Get star statistics."""
        return self._get("stars/stats")


def print_json(data: dict):
    """Pretty print JSON data."""
    print(json.dumps(data, indent=2, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser(description="BijbelQuiz API CLI")
    parser.add_argument("--url", default="http://localhost:7777/v1", help="API base URL")
    parser.add_argument("--api-key", required=True, help="API key for authentication")

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Health command
    subparsers.add_parser("health", help="Check API health")

    # Questions command
    questions_parser = subparsers.add_parser("questions", help="Get quiz questions")
    questions_parser.add_argument("--category", help="Filter by category")
    questions_parser.add_argument("--limit", type=int, default=10, help="Number of questions")
    questions_parser.add_argument("--difficulty", type=int, choices=range(1, 6), help="Difficulty level (1-5)")

    # Progress command
    subparsers.add_parser("progress", help="Get user progress")

    # Stats command
    subparsers.add_parser("stats", help="Get game statistics")

    # Settings command
    subparsers.add_parser("settings", help="Get app settings")

    # Stars subcommands
    stars_parser = subparsers.add_parser("stars", help="Star management commands")
    stars_subparsers = stars_parser.add_subparsers(dest="stars_command", help="Star commands")

    # Stars balance
    stars_subparsers.add_parser("balance", help="Get star balance")

    # Stars add
    add_parser = stars_subparsers.add_parser("add", help="Add stars")
    add_parser.add_argument("amount", type=int, help="Amount of stars to add")
    add_parser.add_argument("reason", help="Reason for adding stars")
    add_parser.add_argument("--lesson-id", help="Lesson ID")

    # Stars spend
    spend_parser = stars_subparsers.add_parser("spend", help="Spend stars")
    spend_parser.add_argument("amount", type=int, help="Amount of stars to spend")
    spend_parser.add_argument("reason", help="Reason for spending stars")
    spend_parser.add_argument("--lesson-id", help="Lesson ID")

    # Stars transactions
    transactions_parser = stars_subparsers.add_parser("transactions", help="Get star transactions")
    transactions_parser.add_argument("--limit", type=int, default=50, help="Number of transactions")
    transactions_parser.add_argument("--type", choices=["earned", "spent", "lesson_reward", "refund"], help="Filter by transaction type")
    transactions_parser.add_argument("--lesson-id", help="Filter by lesson ID")

    # Stars stats
    stars_subparsers.add_parser("stats", help="Get star statistics")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    api = BijbelQuizAPI(args.url, args.api_key)

    try:
        if args.command == "health":
            result = api.health()
            print_json(result)

        elif args.command == "questions":
            result = api.get_questions(args.category, args.limit, args.difficulty)
            print_json(result)

        elif args.command == "progress":
            result = api.get_progress()
            print_json(result)

        elif args.command == "stats":
            result = api.get_stats()
            print_json(result)

        elif args.command == "settings":
            result = api.get_settings()
            print_json(result)

        elif args.command == "stars":
            if args.stars_command == "balance":
                result = api.get_star_balance()
                print_json(result)

            elif args.stars_command == "add":
                result = api.add_stars(args.amount, args.reason, args.lesson_id)
                print_json(result)

            elif args.stars_command == "spend":
                result = api.spend_stars(args.amount, args.reason, args.lesson_id)
                print_json(result)

            elif args.stars_command == "transactions":
                result = api.get_star_transactions(args.limit, args.type, args.lesson_id)
                print_json(result)

            elif args.stars_command == "stats":
                result = api.get_star_stats()
                print_json(result)

            else:
                stars_parser.print_help()

        else:
            parser.print_help()

    except KeyboardInterrupt:
        print("\nOperation cancelled", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()