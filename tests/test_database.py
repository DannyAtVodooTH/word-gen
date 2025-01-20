import unittest
import os
from app.database import WordDatabase

class TestWordDatabase(unittest.TestCase):
    def setUp(self):
        self.test_db = 'test_words.db'
        self.db = WordDatabase(self.test_db)
        self.db.connect()

    def tearDown(self):
        self.db.close()
        if os.path.exists(self.test_db):
            os.remove(self.test_db)

    def test_insert_and_retrieve_word(self):
        test_word = "test"
        self.db.insert_word(test_word)
        words = self.db.get_words_by_length_and_count(len(test_word), 1)
        self.assertEqual(len(words), 1)
        self.assertEqual(words[0], test_word)

    def test_get_words_by_length(self):
        test_words = ["cat", "dog", "rat"]
        for word in test_words:
            self.db.insert_word(word)
        
        words = self.db.get_words_by_length_and_count(3, 3)
        self.assertEqual(len(words), 3)
        self.assertTrue(all(len(word) == 3 for word in words))

if __name__ == '__main__':
    unittest.main() 