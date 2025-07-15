import type { Mention } from "@/lib/constants/parcours";

export interface ParcoursAcademique {
  id: number;
  diplome: string;
  institution: string;
  annee_obtention: number;
  mention: Mention | null;
}

export interface ParcoursProfessionnel {
  id: number;
  poste: string;
  entreprise: string;
  date_debut: string;
  type_contrat: string;
}
