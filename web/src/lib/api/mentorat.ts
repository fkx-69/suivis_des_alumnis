import { api } from "./axios";
import { DemandeMentorat } from "@/types/mentorat";

export async function envoyerDemande(
  mentor_username: string,
  message?: string
) {
  const res = await api.post<DemandeMentorat>("/mentorat/envoyer/", {
    mentor_username,
    message,
  });
  return res.data;
}

export async function fetchMesDemandes() {
  const res = await api.get<DemandeMentorat[]>("/mentorat/mes-demandes/");
  return res.data;
}

export async function repondreDemande(
  id: number,
  statut: "acceptee" | "refusee",
  motif_refus?: string
) {
  const res = await api.patch<DemandeMentorat>(
    `/mentorat/repondre/${id}/`,
    {
      statut,
      motif_refus,
    }
  );
  return res.data;
}
