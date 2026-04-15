# Stage 1: build do frontend
FROM node:20 AS frontend-builder

WORKDIR /app

COPY . .

RUN corepack enable && \
    corepack prepare pnpm@10.2.0 --activate && \
    pnpm install && \
    pnpm build

# Stage 2: imagem final
FROM chatwoot/chatwoot:v4.9.1

USER root

# Copia arquivos backend modificados
COPY app/models/concerns/sort_handler.rb /app/app/models/concerns/sort_handler.rb
COPY app/finders/conversation_finder.rb /app/app/finders/conversation_finder.rb

# Copia os assets compilados do stage anterior
COPY --from=frontend-builder /app/public/packs /app/public/packs
