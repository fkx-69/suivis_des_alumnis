// lib/store/auth.ts
import { create } from "zustand";

interface AuthState {
  user: { id: number; username: string } | null;
  setUser: (u: AuthState["user"]) => void;
  logout: () => void;
}

export const useAuth = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}));