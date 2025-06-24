export interface Message {
  id: number;
  expediteur: number;
  destinataire: number;
  contenu: string;
  date_envoi: string;
  expediteur_username: string;
  destinataire_username: string;
}

export interface Conversation {
  id: number;
  username: string;
  prenom: string;
  nom: string;
  photo_profil: string | null;
  last_message: Message;
}

export interface ConversationDetail {
  user: {
    id: number;
    username: string;
    prenom: string;
    nom: string;
    photo_profil: string | null;
  };
  messages: Message[];
}
