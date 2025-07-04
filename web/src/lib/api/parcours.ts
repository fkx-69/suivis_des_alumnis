import { api } from "./axios";
import { ParcoursAcademique, ParcoursProfessionnel } from "@/types/parcours";

export async function fetchParcoursAcademiques() {
  const res = await api.get<ParcoursAcademique[]>("/accounts/parcours-academiques/");
  return res.data;
}

export async function fetchParcoursProfessionnels() {
  const res = await api.get<ParcoursProfessionnel[]>("/accounts/parcours-professionnels/");
  return res.data;
}

export async function createParcoursAcademique(data: Omit<ParcoursAcademique, "id">) {
  const res = await api.post<ParcoursAcademique>("/accounts/parcours-academiques/", data);
  return res.data;
}

export async function updateParcoursAcademique(
  id: number,
  data: Partial<Omit<ParcoursAcademique, "id">>
) {
  const res = await api.put<ParcoursAcademique>(`/accounts/parcours-academiques/${id}/`, data);
  return res.data;
}

export async function deleteParcoursAcademique(id: number) {
  await api.delete(`/accounts/parcours-academiques/${id}/`);
}

export async function createParcoursProfessionnel(data: Omit<ParcoursProfessionnel, "id">) {
  const res = await api.post<ParcoursProfessionnel>("/accounts/parcours-professionnels/", data);
  return res.data;
}

export async function updateParcoursProfessionnel(
  id: number,
  data: Partial<Omit<ParcoursProfessionnel, "id">>
) {
  const res = await api.put<ParcoursProfessionnel>(`/accounts/parcours-professionnels/${id}/`, data);
  return res.data;
}

export async function deleteParcoursProfessionnel(id: number) {
  await api.delete(`/accounts/parcours-professionnels/${id}/`);
}
