export interface Group {
  id: number;
  nom_groupe: string;
  description: string;
  createur: string;
  membres: string[];
  date_creation: string;
  est_membre: boolean;
  role: string;
}

export interface GroupMessage {
  id: number;
  groupe: number;
  auteur: string;
  contenu: string;
  date_envoi: string;
}
