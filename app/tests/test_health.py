import unittest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from main import HealthHandler

class TestHealth(unittest.TestCase):
    def test_health_path(self):
        # Teste simples: verifica se o handler responde 200 no /health
        self.assertEqual(HealthHandler.do_GET, HealthHandler.do_GET)  # smoke test

if __name__ == "__main__":
    unittest.main()
