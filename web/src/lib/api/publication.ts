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

export async function addComment(publication: number, contenu: string) {
  const res = await api.post(`/publications/commenter/`, {
    publication,
    contenu,
  });
  return res.data as Publication;
}

export async function deleteComment(id: number) {
  await api.delete(`/publications/commentaire/${id}/supprimer/`);
}
