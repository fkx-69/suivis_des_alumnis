export interface ApiEvent {
    lieu: string;
    dateDebut: string | number | Date;
    id: number;
    titre: string;
    description: string;
    date_debut_affiche: string;     // "14-06-2025 à 09h:00"
    date_fin_affiche?: string;
    date_debut: string; // ISO string
    date_fin?: string; 
    image?: string;
  }
  