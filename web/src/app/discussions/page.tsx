"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { fetchConversations } from "@/lib/api/messaging";
import { Conversation } from "@/types/messaging";

export default function DiscussionsPage() {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchConversations()
      .then(setConversations)
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
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Discussions</h1>
      <ul className="space-y-2">
        {conversations.map((conv) => (
          <li key={conv.id}>
            <Link
              href={`/discussions/${conv.username}`}
              className="flex items-center gap-3 p-3 bg-base-200 rounded-md hover:bg-base-300"
            >
              <div className="avatar">
                <div className="w-10 rounded-full bg-base-300 overflow-hidden">
                  {conv.photo_profil ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={conv.photo_profil} alt={conv.username} />
                  ) : (
                    <span className="flex items-center justify-center h-full font-semibold">
                      {conv.username.charAt(0).toUpperCase()}
                    </span>
                  )}
                </div>
              </div>
              <div>
                <p className="font-semibold">
                  {conv.prenom} {conv.nom}
                </p>
                <p className="text-sm opacity-70 truncate max-w-xs">
                  {conv.last_message}
                </p>
              </div>
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
