export const Mentions = {
  passable: "Passable",
  assez_bien: "Assez bien",
  bien: "Bien",
  tres_bien: "Très bien",
};

export type Mention = keyof typeof Mentions;

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
