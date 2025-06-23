export interface Commentaire {
  id: number;
  auteur_username: string;
  contenu: string;
  date_commentaire: string;
}

export interface Publication {
  id: number;
  auteur_username: string;
  texte: string | null;
  photo: string | null;
  video: string | null;
  date_publication: string;
  commentaires: Commentaire[];
}
