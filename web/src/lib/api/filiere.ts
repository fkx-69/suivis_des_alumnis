import { api } from "./axios";

export interface Filiere {
  code: string;
  nom_complet: string;
}

export async function fetchFilieres() {
  const res = await api.get<Filiere[]>("/filiere/");
  return res.data;
}