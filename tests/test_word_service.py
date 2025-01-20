import unittest
import os
from app.word_service import WordService
import tempfile

class TestWordService(unittest.TestCase):
    def setUp(self):
        self.test_db = 'test_words.db'
        self.word_service = WordService(self.test_db)
        self.temp_dir = tempfile.mkdtemp()
        self.words_file = os.path.join(self.temp_dir, 'test_words.txt')

    def tearDown(self):
        self.word_service.close()
        if os.path.exists(self.test_db):
            os.remove(self.test_db)
        if os.path.exists(self.words_file):
            os.remove(self.words_file)
        os.rmdir(self.temp_dir)

    def test_initialize_from_file(self):
        with open(self.words_file, 'w') as f:
            f.write('cat\ndog\nrat\n')

        self.word_service.initialize_from_file(self.words_file)
        words = self.word_service.get_random_words(3, 3)
        self.assertEqual(len(words), 3)

    def test_get_random_words(self):
        with open(self.words_file, 'w') as f:
            f.write('cat\ndog\nrat\n')

        self.word_service.initialize_from_file(self.words_file)
        words = self.word_service.get_random_words(3, 2)
        self.assertEqual(len(words), 2)
        self.assertTrue(all(len(word) == 3 for word in words))

if __name__ == '__main__':
    unittest.main() 