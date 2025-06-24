import { api } from "./axios";
import { Conversation, Message } from "@/types/messaging";

export async function fetchConversations() {
  const res = await api.get<Conversation[]>("/messaging/conversations/");
  return res.data;
}

export async function fetchMessages(username: string) {
  const res = await api.get<Message[]>(`/messaging/with/${username}/`);
  return res.data;
}
