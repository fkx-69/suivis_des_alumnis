export interface User {
  id:           number;
  email:        string;
  username:     string;
  nom:          string;
  prenom:       string;
  role:         string;
  photo_profil: null;
  photo_couverture?: string | null;
  biographie:   null;
}

export interface LoginPayload {
    email: string;
    password: string;
  }


  
  export interface LoginResponse {
  refresh: string;
  access: string;
  user: User;
    }

export interface UserForm {
  email:    string;
  username: string;
  nom:      string;
  prenom:   string;
  password: string;
}



export interface StudentRegisterPayload {
    user:         UserForm;
    filiere:      string;
    niveau_etude: string;
    annee_entree: number;
    role:         string;
}
export interface AlumniRegisterPayload {
    user:             UserForm;
    date_fin_cycle:   string;
    secteur_activite?: string;
    situation_pro:    string;
    poste_actuel?:     string;
    nom_entreprise?:   string;
    filiere:          string;
    role:             string;
}

export interface UpdateProfilePayload {
  username?: string;
  nom?: string;
  prenom?: string;
  photo_profil?: string;
  photo_couverture?: string;
  biographie?: string;
}

export interface ChangeEmailPayload {
  email: string;
}


