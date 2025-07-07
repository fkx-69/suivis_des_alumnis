"use client";

import { useEffect, useState } from "react";
import { fetchPublications, addComment } from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import PublicationCard from "@/components/PublicationCard";

export default function PublicationsFeed() {
  const [publications, setPublications] = useState<Publication[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPublications()
      .then(setPublications)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

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
      <div className="flex justify-center p-8">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {publications.length > 0 ? (
        publications.map((p) => (
          <PublicationCard key={p.id} publication={p} onComment={(v) => handleComment(p.id, v)} />
        ))
      ) : (
        <p className="text-center text-base-content/70">Aucune publication pour le moment.</p>
      )}
    </div>
  );
}
