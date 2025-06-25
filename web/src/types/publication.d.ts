export interface Commentaire {
  id: number;
  publication: number;
  auteur_username: string;
  auteur_photo_profil: string | null;
  contenu: string;
  date_commentaire: string;
}

export interface Publication {
  id: number;
  auteur_username: string;
  auteur_photo_profil: string | null;
  texte: string | null;
  photo: string | null;
  video: string | null;
  date_publication: string;
  commentaires: Commentaire[];
  nombres_commentaires?: number;
}
