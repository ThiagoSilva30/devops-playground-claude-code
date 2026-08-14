FROM python:3.11-slim

WORKDIR /app

# Copiar código da aplicação
COPY app/ /app/

# Expor porta
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health').read()"

# Variáveis de ambiente padrão
ENV HOST=0.0.0.0 \
    PORT=8080 \
    ENVIRONMENT=prod

# Executar aplicação
CMD ["python3", "main.py"]
