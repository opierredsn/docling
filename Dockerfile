FROM python:3.11-slim-bookworm

WORKDIR /app

# Instalar dependências do sistema necessárias
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    curl \
    wget \
    git \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurações de ambiente
ENV HF_HOME=/tmp/
ENV TORCH_HOME=/tmp/
ENV OMP_NUM_THREADS=4
ENV PYTHONUNBUFFERED=1

# Criar o arquivo minimal.py
RUN echo 'from docling.pipeline.standard_pdf_pipeline import StandardPdfPipeline\n\
def main():\n\
    pipeline = StandardPdfPipeline()\n\
    print("Pipeline initialized and ready to process PDFs")\n\
\n\
if __name__ == "__main__":\n\
    main()' > minimal.py

# Instalar docling com suporte CPU
RUN pip install --no-cache-dir docling --extra-index-url https://download.pytorch.org/whl/cpu

# Preparar modelos necessários
RUN python -c 'from deepsearch_glm.utils.load_pretrained_models import load_pretrained_nlp_models; load_pretrained_nlp_models(verbose=True);' && \
    python -c 'from docling.pipeline.standard_pdf_pipeline import StandardPdfPipeline; StandardPdfPipeline.download_models_hf(force=True);'

# Porta (ajuste se necessário)
EXPOSE 8000

# Comando para iniciar
CMD ["python", "minimal.py"]