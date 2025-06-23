export interface ParcoursAcademique {
  id: number;
  diplome: string;
  institution: string;
  annee_obtention: number;
  mention: string | null;
}

export interface ParcoursProfessionnel {
  id: number;
  poste: string;
  entreprise: string;
  date_debut: string;
  type_contrat: string;
}
