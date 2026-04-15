# Stage 1: build do frontend
FROM node:20 AS frontend-builder

WORKDIR /app

# Copia o projeto inteiro
COPY . .

# Instala dependências e compila
RUN npm install -g yarn && \
    yarn install && \
    yarn build

# Stage 2: imagem final
FROM chatwoot/chatwoot:v4.9.1

USER root

# Copia arquivos backend modificados
COPY app/models/concerns/sort_handler.rb /app/app/models/concerns/sort_handler.rb
COPY app/finders/conversation_finder.rb /app/app/finders/conversation_finder.rb

# Copia os assets compilados do stage anterior
COPY --from=frontend-builder /app/public/packs /app/public/packs
