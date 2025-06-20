export interface Report {
  id: number;
  reported_by: number;
  reported_user: {
    id: number;
    username: string;
    email: string;
  };
  reason: string;
  created_at: string;
}
