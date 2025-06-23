import { api } from "./axios";
import { SituationProStat, DomaineStat } from "@/types/stats";

export async function fetchSituationStats() {
  const res = await api.get<SituationProStat[]>("/statistiques/situation/");
  return res.data;
}

export async function fetchDomaineStats(filiereId: number) {
  const res = await api.get<DomaineStat[]>(`/statistiques/domaines/${filiereId}/`);
  return res.data;
}
