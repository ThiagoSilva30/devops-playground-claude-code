from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import logging
import os
import signal
from threading import Lock
from urllib.parse import urlparse

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class Metrics:
    def __init__(self):
        self.lock = Lock()
        self.requests_total = 0
        self.requests_health = 0
        self.requests_metrics = 0
        self.requests_not_found = 0

    def record_request(self, path: str) -> None:
        clean_path = urlparse(path).path
        with self.lock:
            self.requests_total += 1
            if clean_path == "/health":
                self.requests_health += 1
            elif clean_path == "/metrics":
                self.requests_metrics += 1
            else:
                self.requests_not_found += 1

    def get_metrics(self):
        with self.lock:
            return {
                "requests_total": self.requests_total,
                "requests_health": self.requests_health,
                "requests_metrics": self.requests_metrics,
                "requests_not_found": self.requests_not_found,
            }

metrics = Metrics()

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        metrics.record_request(self.path)
        clean_path = urlparse(self.path).path

        if clean_path == "/health":
            self._respond(200, {"status": "ok"})
        elif clean_path == "/metrics":
            self._respond(200, metrics.get_metrics())
        else:
            self._respond(404, {"error": "not found"})

    def _respond(self, status_code, data):
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        logger.info("%s - %s" % (self.client_address[0], format % args))

if __name__ == "__main__":
    host = os.getenv("HOST", "127.0.0.1")
    port_str = os.getenv("PORT", "8080")

    try:
        port = int(port_str)
        if not (1 <= port <= 65535):
            raise ValueError(f"Porta inválida: {port} (deve estar entre 1 e 65535)")
    except ValueError as e:
        logger.error(f"Erro ao validar PORT: {e}")
        exit(1)

    try:
        server = HTTPServer((host, port), HealthHandler)
        logger.info(f"Servidor rodando em {host}:{port}")

        def shutdown_handler(sig, frame):
            logger.info("Encerrando servidor...")
            server.shutdown()

        signal.signal(signal.SIGINT, shutdown_handler)
        signal.signal(signal.SIGTERM, shutdown_handler)

        server.serve_forever()
    except OSError as e:
        logger.error(f"Erro ao iniciar servidor: {e}")
        exit(1)
    except Exception as e:
        logger.error(f"Erro inesperado: {e}", exc_info=True)
        exit(1)
