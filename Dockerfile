FROM chatwoot/chatwoot:v4.9.1

# Copia os arquivos customizados
COPY app/javascript/dashboard/store/modules/conversations/actions/messageReadActions.js \
     /app/app/javascript/dashboard/store/modules/conversations/actions/messageReadActions.js

COPY app/models/concerns/sort_handler.rb \
     /app/app/models/concerns/sort_handler.rb

COPY app/finders/conversation_finder.rb \
     /app/app/finders/conversation_finder.rb

COPY app/javascript/dashboard/constants/globals.js \
     /app/app/javascript/dashboard/constants/globals.js

COPY app/javascript/dashboard/components/widgets/conversation/ConversationBasicFilter.vue \
     /app/app/javascript/dashboard/components/widgets/conversation/ConversationBasicFilter.vue

COPY app/javascript/dashboard/i18n/locale/pt_BR/chatlist.json \
     /app/app/javascript/dashboard/i18n/locale/pt_BR/chatlist.json

COPY app/javascript/dashboard/i18n/locale/pt/chatlist.json \
     /app/app/javascript/dashboard/i18n/locale/pt/chatlist.json
