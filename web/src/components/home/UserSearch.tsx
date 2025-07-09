"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api/axios";
import Link from "next/link";

interface UserBasic {
  username: string;
  prenom: string;
  nom: string;
}

export default function UserSearch() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<UserBasic[]>([]);

  useEffect(() => {
    if (query.length < 2) {
      setResults([]);
      return;
    }
    const handler = setTimeout(() => {
      api
        .get<UserBasic[]>(`/accounts/search/?q=${encodeURIComponent(query)}`)
        .then((r) => setResults(r.data))
        .catch(console.error);
    }, 300);

    return () => clearTimeout(handler);
  }, [query]);

  return (
    <div className="relative w-full max-w-md mx-auto">
      <input
        type="text"
        className="input input-primary w-full"
        placeholder="Rechercher un utilisateur..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {results.length > 0 && (
        <ul className="absolute z-10 mt-1 w-full bg-base-100 shadow-lg rounded-b-lg max-h-60 overflow-auto">
          {results.map((u) => (
            <li key={u.username} className="px-4 py-2 hover:bg-base-200">
              <Link href={`/profile/${u.username}`}>
                {u.prenom} {u.nom} (@{u.username})
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
