import unittest
import json
from app.webapp import app
from app.word_service import WordService
import tempfile
import os

class TestWebApp(unittest.TestCase):
    def setUp(self):
        app.config['TESTING'] = True
        self.client = app.test_client()
        
        # Set up a test database
        self.test_db = 'test_words.db'
        self.word_service = WordService(self.test_db)
        
        # Create and populate test words file
        self.temp_dir = tempfile.mkdtemp()
        self.words_file = os.path.join(self.temp_dir, 'test_words.txt')
        with open(self.words_file, 'w') as f:
            f.write('hello\nworld\ntest\n')
        
        # Initialize database with test words
        self.word_service.initialize_from_file(self.words_file)
        
        # Set the word service in the app
        import app.webapp as webapp
        webapp.init_word_service(self.word_service)

    def tearDown(self):
        self.word_service.close()
        if os.path.exists(self.test_db):
            os.remove(self.test_db)
        if os.path.exists(self.words_file):
            os.remove(self.words_file)
        os.rmdir(self.temp_dir)

    def test_get_words(self):
        response = self.client.post('/words',
                                  data=json.dumps({'wordLength': 5, 'numberOfWords': 1}),
                                  content_type='application/json')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data)
        self.assertIn('words', data)
        self.assertTrue(isinstance(data['words'], str))

    def test_invalid_request(self):
        response = self.client.post('/words',
                                  data=json.dumps({'wordLength': -1, 'numberOfWords': 1}),
                                  content_type='application/json')
        self.assertEqual(response.status_code, 400)

if __name__ == '__main__':
    unittest.main() 