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
