import axios, { AxiosRequestHeaders } from "axios";
import { toast } from "@/components/ui/toast";

// Création d’une instance pré‑configurée
export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8000/api",
  withCredentials: true, // pour les cookies httpOnly
});

// Intercepteur : attache automatiquement le JWT (stocké en cookie httpOnly)
api.interceptors.request.use((config) => {
  if (typeof window !== "undefined") {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers = {
        ...config.headers,
        Authorization: `Bearer ${token}`,
      } as AxiosRequestHeaders;
    }
  }
  return config;
});

// Intercepteur de réponse : refresh token ou déconnexion automatique
api.interceptors.response.use(
  (response) => {
    console.log("Réponse de l'API :", response.data);
    return response;
  },
  (error) => {
    const message =
      error.response?.data?.non_field_errors?.join(" \n") ||
      error.response?.data?.detail ||
      error.response?.data?.message ||
      error.message ||
      "Une erreur est survenue";
    if (typeof window !== "undefined") {
      toast.error(message);
    }
    console.error("Erreur API :", error);
    return Promise.reject(error);
  }
);
