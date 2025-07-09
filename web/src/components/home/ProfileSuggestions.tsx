"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api/axios";
import ProfileCard from "./ProfileCard";

interface SuggestedUser {
  username: string;
  prenom: string;
  nom: string;
  photo_profil: string | null;
}

export default function ProfileSuggestions() {
  const [suggestions, setSuggestions] = useState<SuggestedUser[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api
      .get<SuggestedUser[]>("/accounts/suggestions/")
      .then((res) => setSuggestions(res.data.slice(0, 3))) // Affiche 3 suggestions
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="space-y-4">
      <h3 className="text-xl font-bold">Suggestions de profils</h3>
      {loading ? (
        <div className="flex justify-center p-4">
          <span className="loading loading-spinner" />
        </div>
      ) : suggestions.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {suggestions.map((user) => (
            <ProfileCard key={user.username} user={user} />
          ))}
        </div>
      ) : (
        <div className="bg-base-200 p-6 rounded-2xl shadow-inner text-center">
          <p className="text-base-content/70">
            Aucune suggestion pour le moment.
          </p>
        </div>
      )}
    </div>
  );
}
