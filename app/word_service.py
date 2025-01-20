import logging
from .database import WordDatabase
import os

class WordService:
    def __init__(self, db_name='words.db'):
        self.db = WordDatabase(db_name)
        self.db.connect()

    def initialize_from_file(self, file_path):
        try:
            if not os.path.exists(file_path):
                logging.error(f"Words file not found: {file_path}")
                raise FileNotFoundError(f"Words file not found: {file_path}")

            with open(file_path, 'r') as file:
                words = [word.strip() for word in file.readlines()]
                if not words:
                    logging.error("Words file is empty")
                    raise ValueError("Words file is empty")

                word_count = 0
                for word in words:
                    if word:
                        self.db.insert_word(word)
                        word_count += 1

                logging.info(f"Initialized database with {word_count} words")
                return word_count
        except FileNotFoundError:
            logging.error(f"Words file not found: {file_path}")
            raise
        except Exception as e:
            logging.error(f"Error initializing words: {e}")
            raise

    def get_random_words(self, length, count):
        return self.db.get_words_by_length_and_count(length, count)

    def close(self):
        self.db.close() 