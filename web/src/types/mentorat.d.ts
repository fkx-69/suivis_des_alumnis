export interface DemandeMentorat {
  id: number;
  etudiant: number;
  etudiant_username: string;
  mentor: number;
  mentor_username: string;
  statut: 'en_attente' | 'acceptee' | 'refusee';
  message: string | null;
  motif_refus: string | null;
  date_demande: string;
  date_maj: string;
}
