import { api } from "./axios";
import { Conversation, ConversationDetail, Message } from "@/types/messaging";

export async function fetchConversations() {
  const res = await api.get<Conversation[]>("/messaging/conversations/");
  return res.data;
}

export async function fetchConversation(username: string) {
  const res = await api.get<ConversationDetail>(`/messaging/with/${username}/`);
  return res.data;
}
