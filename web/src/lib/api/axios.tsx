import axios from "axios";

// Création d’une instance pré‑configurée
export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000/api",
  withCredentials: true, // pour les cookies httpOnly
});

// Intercepteur : attache automatiquement le JWT (stocké en cookie httpOnly)
api.interceptors.request.use((config) => {
  // Ex : lecture d’un token CSRF si besoin
  return config;
});



// Intercepteur de réponse : refresh token ou déconnexion automatique
api.interceptors.response.use((response) => {
  console.log("Réponse de l'API :", response.data);
  return response;
});
