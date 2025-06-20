import { api } from "./axios";
import { Group, GroupMessage } from "@/types/group";

export async function fetchGroups() {
  const res = await api.get<Group[]>("/groups/listes/");
  return res.data;
}

export async function createGroup(data: { nom_groupe: string; description: string }) {
  const res = await api.post<Group>("/groups/creer/", data);
  return res.data;
}

export async function joinGroup(id: number) {
  await api.post(`/groups/${id}/rejoindre/`);
}

export async function leaveGroup(id: number) {
  await api.post(`/groups/${id}/quitter/`);
}

export async function fetchGroupMessages(id: number) {
  const res = await api.get<GroupMessage[]>(`/groups/${id}/messages/`);
  return res.data;
}

export async function sendGroupMessage(id: number, contenu: string) {
  const res = await api.post<GroupMessage>(`/groups/${id}/envoyer-message/`, { contenu });
  return res.data;
}
