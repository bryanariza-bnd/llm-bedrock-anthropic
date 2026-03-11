# 1. Usar imagen base específica
FROM python:3.11-slim-bookworm

# 2. Crear un usuario sin privilegios
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 3. Establecer directorio y permisos
WORKDIR /app
RUN chown appuser:appuser /app

# 4. Instalar dependencias (evitar caché)
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copiar código fuente
COPY --chown=appuser:appuser . .

# 6. Configurar entorno para Streamlit (evita errores de permiso)
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0
ENV STREAMLIT_BROWSER_GATHER_USAGE_STATS=false
ENV STREAMLIT_CONFIG_DIR=/app/.streamlit

# 7. Crear carpeta de configuración y asignar permisos
RUN mkdir -p /app/.streamlit && chown -R appuser:appuser /app/.streamlit

# 8. Cambiar a usuario no root
USER appuser

EXPOSE 8501

ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]