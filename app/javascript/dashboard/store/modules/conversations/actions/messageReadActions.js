import { throwErrorMessage } from 'dashboard/store/utils/api';
import ConversationApi from '../../../../api/inbox/conversation';
import mutationTypes from '../../../mutation-types';
import { MESSAGE_TYPE } from 'shared/constants/messages';

export const shouldMarkAsRead = conversation => {
  if (!conversation) return false;
  const lastMessage = conversation.last_non_activity_message;
  if (!lastMessage) return false;
  return lastMessage.message_type !== MESSAGE_TYPE.INCOMING;
};

export default {
  markMessagesRead: async ({ commit, state }, data) => {
    const { allConversations } = state;
    const conversation = allConversations.find(c => c.id === data.id);
    if (!shouldMarkAsRead(conversation)) return;
    try {
      const {
        data: { id, agent_last_seen_at: lastSeen },
      } = await ConversationApi.markMessageRead(data);
      setTimeout(
        () =>
          commit(mutationTypes.UPDATE_MESSAGE_UNREAD_COUNT, { id, lastSeen }),
        4000
      );
    } catch (error) {
      // Handle error
    }
  },
  markMessagesUnread: async ({ commit }, { id }) => {
    try {
      const {
        data: { agent_last_seen_at: lastSeen, unread_count: unreadCount },
      } = await ConversationApi.markMessagesUnread({ id });
      commit(mutationTypes.UPDATE_MESSAGE_UNREAD_COUNT, {
        id,
        lastSeen,
        unreadCount,
      });
    } catch (error) {
      throwErrorMessage(error);
    }
  },
};
