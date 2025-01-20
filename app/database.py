import sqlite3
import logging
from flask import g, current_app

class WordDatabase:
    def __init__(self, db_name='words.db'):
        self.db_name = db_name
        self.conn = None
        self.cursor = None

    def connect(self):
        try:
            if not self.conn:
                self.conn = sqlite3.connect(self.db_name, check_same_thread=False)
                self.cursor = self.conn.cursor()
            self.create_table()
        except sqlite3.Error as e:
            logging.error(f"Database connection error: {e}")
            raise

    def create_table(self):
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS words
            (word TEXT PRIMARY KEY, length INTEGER)
        ''')
        self.conn.commit()

    def insert_word(self, word):
        try:
            self.cursor.execute(
                'INSERT OR REPLACE INTO words (word, length) VALUES (?, ?)',
                (word, len(word))
            )
            self.conn.commit()
        except sqlite3.Error as e:
            logging.error(f"Error inserting word: {e}")
            raise

    def get_words_by_length_and_count(self, length, count):
        try:
            self.cursor.execute(
                'SELECT word FROM words WHERE length = ? ORDER BY RANDOM() LIMIT ?',
                (length, count)
            )
            return [row[0] for row in self.cursor.fetchall()]
        except sqlite3.Error as e:
            logging.error(f"Error retrieving words: {e}")
            raise

    def close(self):
        if self.conn:
            self.conn.close()
            self.conn = None
            self.cursor = None 