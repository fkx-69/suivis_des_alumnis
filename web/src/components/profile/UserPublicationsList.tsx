"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/lib/api/authContext";
import { fetchUserPublications, addComment } from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import PublicationCard from "@/components/PublicationCard";

export default function UserPublicationsList() {
  const { user } = useAuth();
  const [publications, setPublications] = useState<Publication[]>([]);
  const [loading, setLoading] = useState(true);
  const [visibleCount, setVisibleCount] = useState(3);

  useEffect(() => {
    if (user?.username) {
      fetchUserPublications(user.username)
        .then(setPublications)
        .catch(console.error)
        .finally(() => setLoading(false));
    }
  }, [user]);

  const handleComment = async (id: number, value: string) => {
    if (!value.trim()) return;
    try {
      const updatedPub = await addComment(id, value);
      setPublications((prev) =>
        prev.map((p) => (p.id === id ? { ...p, commentaires: updatedPub.commentaires } : p))
      );
    } catch (error) {
      console.error("Failed to add comment:", error);
    }
  };

  if (loading) {
    return (
      <div className="text-center p-8">
        <span className="loading loading-lg loading-spinner"></span>
      </div>
    );
  }

  return (
    <div className="bg-base-100 p-6 rounded-2xl shadow-lg">
      <h3 className="text-xl font-bold mb-4">Mes Publications</h3>
      {publications.length > 0 ? (
        <>
          <ul className="space-y-4">
            {publications.slice(0, visibleCount).map((p) => (
              <li key={p.id}>
                <PublicationCard
                  publication={p}
                  onComment={(v) => handleComment(p.id, v)}
                />
              </li>
            ))}
          </ul>
          {visibleCount < publications.length && (
            <div className="text-center mt-4">
              <button
                className="btn btn-sm"
                onClick={() => setVisibleCount((c) => c + 3)}
              >
                Charger plus
              </button>
            </div>
          )}
        </>
      ) : (
        <p className="text-neutral-500 text-center py-8">Vous n'avez encore rien publié.</p>
      )}
    </div>
  );
}
