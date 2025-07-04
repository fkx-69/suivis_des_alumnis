import { api } from "./axios";
import { Publication } from "@/types/publication";

export async function fetchPublications() {
  const res = await api.get<Publication[]>("/publications/fil/");
  return res.data;
}

export async function createPublication(data: FormData) {
  const res = await api.post<Publication>("/publications/creer/", data);
  return res.data;
}

export async function deletePublication(id: number) {
  await api.delete(`/publications/${id}/supprimer/`);
}

export async function addComment(id: number, contenu: string) {
  const res = await api.post(`/publications/${id}/commentaires/`, {
    contenu,
  });
  return res.data as Publication;
}

export async function deleteComment(id: number) {
  await api.delete(`/publications/commentaire/${id}/supprimer/`);
}

export async function fetchUserPublications(username: string) {
  const res = await api.get<Publication[]>(`/publications/utilisateur/${username}/`);
  return res.data;
}
