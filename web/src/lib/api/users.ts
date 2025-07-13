import { api } from "./axios";

export interface UserProfile {
  id: number;
  username: string;
  nom: string;
  prenom: string;
  photo_profil: string;
  biographie: string;
  role: 'alumni' | 'etudiant' | 'enseignant';
}

export const fetchUserProfile = async (username: string): Promise<UserProfile> => {
  const response = await api.get<UserProfile>(`/accounts/${username}/`);
  return response.data;
};
