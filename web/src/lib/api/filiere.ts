import { api } from "./axios";

export interface Filiere {
  id: number;
  code: string;
  nom_complet: string;
}

export async function fetchFilieres() {
  const res = await api.get<Filiere[]>("/filiere/");
  return res.data;
}

export async function createFiliere(data: { code: string; nom_complet: string }) {
  const res = await api.post<Filiere>("/filiere/", data);
  return res.data;
}

export async function deleteFiliere(id: number) {
  await api.delete(`/filiere/${id}/`);
}