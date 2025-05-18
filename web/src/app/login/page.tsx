"use client";

import React, { useState } from "react";
import { loginUser } from "../../../components/backend";

const Page: React.FC = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError("Veuillez remplir tous les champs.");
      return;
    }

    // Logique de connexion ici
    console.log("Email:", email, "Mot de passe:", password);
    setError("");
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-100">
      <div className="bg-white p-8 rounded-2xl shadow-xl w-full max-w-md">
        <h2 className="text-2xl font-bold mb-6 text-center">Connexion</h2>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block mb-1 text-sm font-medium">Email</label>
            <input
              type="email"
              className="w-full input input-primary px-4 py-2 border rounded-xl"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="exemple@mail.com"
            />
          </div>
          <div>
            <label className="block mb-1 text-sm font-medium">
              Mot de passe
            </label>
            <input
              type="password"
              className="w-full px-4 py-2 border rounded-xl input input-primary"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
            />
          </div>
          {error && <p className="text-red-500 text-sm">{error}</p>}
          <button
            type="submit"
            className="btn btn-primary px-4 py-2 border rounded-xl transition duration-200 justify-center w-full "
            onClick={() => {
              // Appel de la fonction de connexion
              loginUser({ email: email, password: password })
                .then((response) => {
                  console.log("Connexion réussie:", response.data);
                })
                .catch((error) => {
                  console.error("Erreur de connexion:", error);
                  setError("Email ou mot de passe invalid.");
                });
            }}
          >
            Se connecter
          </button>
        </form>
        <div className="mt-4 text-sm text-center text-gray-500">
          Vous n'avez pas de compte ?{" "}
          <a href="/signIn" className="text-blue-600 hover:underline">
            Inscrivez-vous
          </a>
        </div>
      </div>
    </div>
  );
};

export default Page;
