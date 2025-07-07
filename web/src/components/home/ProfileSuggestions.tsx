"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api/axios";
import Link from "next/link";

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
      .then((res) => setSuggestions(res.data))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center p-4">
        <span className="loading loading-spinner" />
      </div>
    );
  }

  return (
    <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
      <h3 className="text-xl font-bold mb-4">Suggestions de profils</h3>
      {suggestions.length ? (
        <ul className="space-y-4">
          {suggestions.map((u) => {
            const photoUrl = u.photo_profil
              ? `http://127.0.0.1:8000/${u.photo_profil}`
              : `https://ui-avatars.com/api/?name=${u.prenom}+${u.nom}&background=random`;
            return (
              <li key={u.username} className="flex items-center gap-4">
                <div className="avatar">
                  <div className="w-10 h-10 rounded-full">
                    <img src={photoUrl} alt={u.username} />
                  </div>
                </div>
                <div className="flex-1">
                  <p className="font-semibold text-sm">
                    {u.prenom} {u.nom}
                  </p>
                  <p className="text-xs text-base-content/70">@{u.username}</p>
                </div>
                <Link href={`/profile/${u.username}`} className="btn btn-xs btn-primary">
                  Voir
                </Link>
              </li>
            );
          })}
        </ul>
      ) : (
        <p className="text-base-content/70">Aucune suggestion pour le moment.</p>
      )}
    </div>
  );
}
