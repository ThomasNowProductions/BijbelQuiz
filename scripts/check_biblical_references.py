#!/usr/bin/env python3
"""
Script to check biblical references in questions-nl-sv.json 
against the BibleBookMapper in bible_book_mapper.dart

This script validates that all biblical book names used in the questions
can be properly mapped by the Dart BibleBookMapper class.
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional


class BiblicalReferenceChecker:
    """Check biblical references against BibleBookMapper compatibility"""
    
    # Book name mappings from the Dart BibleBookMapper (normalized names)
    DART_MAPPER_BOOKS = {
        # Old Testament
        'Genesis': 1,
        'Exodus': 2,
        'Leviticus': 3,
        'Numeri': 4,
        'Deuteronomium': 5,
        'Jozua': 6,
        'Richteren': 7,
        'Ruth': 8,
        '1 Samuel': 9,
        '2 Samuel': 10,
        '1 Koningen': 11,
        '2 Koningen': 12,
        '1 Kronieken': 13,
        '2 Kronieken': 14,
        'Ezra': 15,
        'Nehemia': 16,
        'Esther': 17,
        'Job': 18,
        'Psalmen': 19,
        'Spreuken': 20,
        'Prediker': 21,
        'Hooglied': 22,
        'Jesaja': 23,
        'Jeremia': 24,
        'Klaagliederen': 25,
        'Ezechiel': 26,
        'Daniel': 27,
        'Hosea': 28,
        'Joel': 29,
        'Amos': 30,
        'Obadja': 31,
        'Jona': 32,
        'Micha': 33,
        'Nahum': 34,
        'Habakuk': 35,
        'Sefanja': 36,
        'Haggai': 37,
        'Zacharia': 38,
        'Maleachi': 39,
        # New Testament
        'Nieuwe testament': 40,
        'Mattheus': 41,
        'Markus': 42,
        'Lukas': 43,
        'Johannes': 44,
        'Handelingen': 45,
        'Romeinen': 46,
        '1 Korintiers': 47,
        '2 Korintiers': 48,
        'Galaten': 49,
        'Efeziers': 50,
        'Filippenzen': 51,
        'Kolossenzen': 52,
        '1 Tessalonicenzen': 53,
        '2 Tessalonicenzen': 54,
        '1 Timoteus': 55,
        '2 Timoteus': 56,
        'Titus': 57,
        'Filemon': 58,
        'Hebreeen': 59,
        'Jakobus': 60,
        '1 Petrus': 61,
        '2 Petrus': 62,
        '1 Johannes': 63,
        '2 Johannes': 64,
        '3 Johannes': 65,
        'Judas': 66,
        'Openbaring': 67,
    }
    
    # Reverse mapping for getting original names from normalized names
    REVERSE_MAPPING = {
        'Ezechiel': 'Ezechiël',
        'Daniel': 'Daniël',
        'Joel': 'Joël',
        '1 Korintiers': '1 Korintiërs',
        '2 Korintiers': '2 Korintiërs',
        'Efeziers': 'Efeziërs',
        'Hebreeen': 'Hebreeën',
        'Mattheus': 'Mattheüs',
        '1 Timoteus': '1 Timotheüs',
        '2 Timoteus': '2 Timotheüs',
        '1 Samuel': '1 Samuël',
        '2 Samuel': '2 Samuël',
    }

    def __init__(self):
        self.valid_books = set(self.DART_MAPPER_BOOKS.keys())
        self.results = {
            'valid_references': [],
            'invalid_references': [],
            'no_reference': [],
            'statistics': {}
        }

    def normalize_book_name(self, book_name: str) -> str:
        """Normalize book name the same way the Dart mapper does"""
        normalized = book_name.strip()
        
        # Convert special characters to ASCII equivalents (same as Dart _normalizeBookName)
        normalized = (normalized
                     .replace('ë', 'e')
                     .replace('ï', 'i')
                     .replace('é', 'e')
                     .replace('è', 'e')
                     .replace('ê', 'e')
                     .replace('â', 'a')
                     .replace('ô', 'o')
                     .replace('û', 'u')
                     .replace('î', 'i')
                     .replace('ä', 'a')
                     .replace('ö', 'o')
                     .replace('ü', 'u')
                     .replace('ÿ', 'y')
                     .replace('ç', 'c'))
        
        # Remove any remaining special characters using regex
        normalized = re.sub(r'[^\w\s]', '', normalized).strip()
        
        return normalized

    def extract_book_names(self, reference: str) -> List[str]:
        """Extract book names from a biblical reference"""
        if not reference or reference.strip().lower() == 'null':
            return []
        
        # Clean up the reference
        ref = reference.strip()
        
        # Handle various reference patterns
        book_names = []
        
        # Pattern 1: "BookName chapter:verse" or "BookName chapter"
        # Handle ranges like "Genesis 2 en 3", "1 en 2 Korinthe"
        en_pattern = r'^(.+?)\s+(?:\d+\s+en\s+\d+|\d+\s*en\s*[a-zA-Z]*)'
        if re.match(en_pattern, ref):
            match = re.match(en_pattern, ref)
            if match:
                book_names.append(match.group(1).strip())
        
        # Pattern 2: "1 en 2 BookName" 
        multi_book_pattern = r'^(?:\d+\s+en\s+\d+)\s+(.+?)(?:\s+\d+|$)'
        if re.match(multi_book_pattern, ref):
            match = re.match(multi_book_pattern, ref)
            if match:
                book_names.append(match.group(1).strip())
        
        # Pattern 3: Single book name followed by chapter/verse
        single_pattern = r'^([a-zA-ZÀ-ſ\s\d\.]+?)(?:\s+\d+|$)'
        if re.match(single_pattern, ref):
            match = re.match(single_pattern, ref)
            if match:
                book_name = match.group(1).strip()
                # Make sure it's not just numbers
                if not book_name.isdigit():
                    book_names.append(book_name)
        
        # Also try to extract just the first word/phrase that looks like a book name
        simple_pattern = r'^([a-zA-ZÀ-ſ][a-zA-ZÀ-ſ\s\d\.]*?)(?:\s+\d+|$)'
        if re.match(simple_pattern, ref):
            match = re.match(simple_pattern, ref)
            if match:
                candidate = match.group(1).strip()
                # Filter out obvious non-book names
                if (not candidate.isdigit() and 
                    len(candidate) > 2 and
                    not re.match(r'^\d+$', candidate)):
                    book_names.append(candidate)
        
        return list(set(book_names))  # Remove duplicates

    def check_reference(self, question_id: str, reference: str) -> Tuple[bool, List[str], List[str]]:
        """Check a single biblical reference"""
        if not reference or reference.strip().lower() == 'null':
            self.results['no_reference'].append({
                'id': question_id,
                'reference': reference
            })
            return True, [], []
        
        book_names = self.extract_book_names(reference)
        valid_books = []
        invalid_books = []
        
        for book_name in book_names:
            normalized = self.normalize_book_name(book_name)
            
            if normalized in self.valid_books:
                # Get the original Dutch name for display
                original_name = self.REVERSE_MAPPING.get(normalized, normalized)
                valid_books.append({
                    'original': book_name,
                    'normalized': normalized,
                    'dart_format': original_name
                })
            else:
                invalid_books.append({
                    'original': book_name,
                    'normalized': normalized
                })
        
        return len(invalid_books) == 0, valid_books, invalid_books

    def check_questions_file(self, json_file_path: str) -> Dict:
        """Check all questions in the JSON file"""
        print(f"Reading questions from: {json_file_path}")
        
        with open(json_file_path, 'r', encoding='utf-8') as f:
            questions = json.load(f)
        
        print(f"Found {len(questions)} questions to check")
        
        valid_count = 0
        invalid_count = 0
        no_ref_count = 0
        
        for question in questions:
            question_id = question.get('id', 'unknown')
            reference = question.get('biblicalReference')
            
            is_valid, valid_books, invalid_books = self.check_reference(question_id, reference)
            
            if not reference or str(reference).lower() == 'null':
                no_ref_count += 1
            elif is_valid:
                valid_count += 1
                self.results['valid_references'].append({
                    'id': question_id,
                    'reference': reference,
                    'books': valid_books
                })
            else:
                invalid_count += 1
                self.results['invalid_references'].append({
                    'id': question_id,
                    'reference': reference,
                    'books': invalid_books
                })
        
        # Set statistics
        self.results['statistics'] = {
            'total_questions': len(questions),
            'questions_with_references': len(questions) - no_ref_count,
            'valid_references': valid_count,
            'invalid_references': invalid_count,
            'no_references': no_ref_count
        }
        
        return self.results

    def print_results(self):
        """Print detailed results"""
        stats = self.results['statistics']
        
        print("\n" + "="*60)
        print("BIBLICAL REFERENCES VALIDATION REPORT")
        print("="*60)
        print(f"Total questions: {stats['total_questions']}")
        print(f"Questions with biblical references: {stats['questions_with_references']}")
        print(f"Valid references: {stats['valid_references']}")
        print(f"Invalid references: {stats['invalid_references']}")
        print(f"Questions without references: {stats['no_references']}")
        
        if self.results['valid_references']:
            print(f"\n✓ VALID REFERENCES ({len(self.results['valid_references'])}):")
            print("-" * 40)
            for ref in self.results['valid_references'][:10]:  # Show first 10
                books = ', '.join([f"{book['original']} (→ {book['dart_format']})" for book in ref['books']])
                print(f"  {ref['id']}: {ref['reference']}")
                print(f"    Books: {books}")
            if len(self.results['valid_references']) > 10:
                print(f"    ... and {len(self.results['valid_references']) - 10} more")
        
        if self.results['invalid_references']:
            print(f"\n✗ INVALID REFERENCES ({len(self.results['invalid_references'])}):")
            print("-" * 40)
            for ref in self.results['invalid_references']:
                books = ', '.join([f"{book['original']} (→ {book['normalized']})" for book in ref['books']])
                print(f"  {ref['id']}: {ref['reference']}")
                print(f"    Unrecognized books: {books}")
        
        if self.results['no_reference']:
            print(f"\n- NO REFERENCES ({len(self.results['no_reference'])}):")
            print("-" * 40)
            for ref in self.results['no_reference'][:5]:  # Show first 5
                print(f"  {ref['id']}: {ref['reference']}")
            if len(self.results['no_reference']) > 5:
                print(f"    ... and {len(self.results['no_reference']) - 5} more")

    def print_summary(self):
        """Print just the summary"""
        stats = self.results['statistics']
        
        print("\n" + "="*60)
        print("SUMMARY")
        print("="*60)
        
        success_rate = (stats['valid_references'] / stats['questions_with_references'] * 100) if stats['questions_with_references'] > 0 else 0
        
        print(f"Success rate: {success_rate:.1f}% ({stats['valid_references']}/{stats['questions_with_references']} references)")
        
        if stats['invalid_references'] == 0:
            print("✓ All biblical references are compatible with BibleBookMapper!")
        else:
            print(f"✗ {stats['invalid_references']} references need to be fixed")


def main():
    """Main function"""
    # Paths
    base_dir = Path(__file__).parent.parent
    questions_file = base_dir / "app/assets/questions-nl-sv.json"
    mapper_file = base_dir / "app/lib/utils/bible_book_mapper.dart"
    
    print("Biblical Reference Checker")
    print("=" * 40)
    
    # Check if files exist
    if not questions_file.exists():
        print(f"❌ Questions file not found: {questions_file}")
        return 1
    
    if not mapper_file.exists():
        print(f"❌ Mapper file not found: {mapper_file}")
        return 1
    
    print(f"✓ Questions file: {questions_file}")
    print(f"✓ Mapper file: {mapper_file}")
    
    # Run check
    checker = BiblicalReferenceChecker()
    results = checker.check_questions_file(str(questions_file))
    
    # Print results
    checker.print_results()
    checker.print_summary()
    
    # Return appropriate exit code
    return 0 if results['statistics']['invalid_references'] == 0 else 1


if __name__ == "__main__":
    exit(main())