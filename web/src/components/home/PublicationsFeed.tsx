"use client";

import { useEffect, useState } from "react";
import {
  fetchPublications,
  deletePublication,
  deleteComment,
} from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import { Carousel } from "@/components/ui/carousel";
import PublicationCard from "../PublicationCard";
import PublicationModal from "../PublicationModal";
import { addComment } from "@/lib/api/publication";
import DeleteConfirmModal from "../DeleteConfirmModal";

export default function PublicationsFeed() {
  const [publications, setPublications] = useState<Publication[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedPublication, setSelectedPublication] =
    useState<Publication | null>(null);
  const [toDelete, setToDelete] = useState<Publication | null>(null);

  const handleComment = async (id: number, value: string) => {
    if (!value.trim()) return;
    const comment = await addComment(id, value);
    setPublications((prev) =>
      prev.map((p) =>
        p.id === id
          ? {
              ...p,
              commentaires: [...p.commentaires, comment],
              nombres_commentaires: (p.nombres_commentaires || 0) + 1,
            }
          : p
      )
    );
    if (selectedPublication?.id === id) {
      setSelectedPublication((prev) =>
        prev
          ? {
              ...prev,
              commentaires: [...prev.commentaires, comment],
              nombres_commentaires: (prev.nombres_commentaires || 0) + 1,
            }
          : null
      );
    }
  };

  const handleDeleteComment = async (pubId: number, commentId: number) => {
    await deleteComment(commentId);
    setPublications((prev) =>
      prev.map((p) =>
        p.id === pubId
          ? {
              ...p,
              commentaires: p.commentaires.filter((c) => c.id !== commentId),
              nombres_commentaires: (p.nombres_commentaires || 1) - 1,
            }
          : p
      )
    );
    if (selectedPublication?.id === pubId) {
      setSelectedPublication((prev) =>
        prev
          ? {
              ...prev,
              commentaires: prev.commentaires.filter((c) => c.id !== commentId),
              nombres_commentaires: (prev.nombres_commentaires || 1) - 1,
            }
          : null
      );
    }
  };

  const confirmDelete = async () => {
    if (!toDelete) return;
    await deletePublication(toDelete.id);
    setPublications((prev) => prev.filter((p) => p.id !== toDelete.id));
    if (selectedPublication?.id === toDelete.id) {
      setSelectedPublication(null);
    }
    setToDelete(null);
  };

  useEffect(() => {
    fetchPublications()
      .then(setPublications)
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center p-8 h-64 items-center">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  return (
    <div className="w-full">
      <h2 className="text-3xl font-bold text-center mb-2">Fil d&apos;actualité</h2>
      {publications.length > 0 ? (
        <Carousel>
          {publications.map((p) => (
            <div key={p.id} className="w-full snap-center flex-shrink-0">
              <PublicationCard
                publication={p}
                onComment={(v) => handleComment(p.id, v)}
                onCardClick={() => setSelectedPublication(p)}
                onDelete={() => setToDelete(p)}
                onDeleteComment={(cid) => handleDeleteComment(p.id, cid)}
              />
            </div>
          ))}
        </Carousel>
      ) : (
        <div className="text-center text-base-content/70 p-8 bg-base-200 rounded-2xl">
          <p>Aucune publication pour le moment.</p>
        </div>
      )}

      <PublicationModal
        publication={selectedPublication}
        onClose={() => setSelectedPublication(null)}
      />

      {toDelete && (
        <DeleteConfirmModal
          title="Supprimer la publication"
          message="Cette action est irreversible."
          onDelete={confirmDelete}
          onCancel={() => setToDelete(null)}
        />
      )}
    </div>
  );
}
