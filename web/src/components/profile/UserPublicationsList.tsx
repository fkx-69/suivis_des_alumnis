"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/lib/api/authContext";
import {
  fetchUserPublications,
  addComment,
  deletePublication,
  deleteComment,
} from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import PublicationCard from "@/components/PublicationCard";
import DeleteConfirmModal from "@/components/DeleteConfirmModal";

export default function UserPublicationsList() {
  const { user } = useAuth();
  const [publications, setPublications] = useState<Publication[]>([]);
  const [loading, setLoading] = useState(true);
  const [toDelete, setToDelete] = useState<Publication | null>(null);

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
  };

  const confirmDelete = async () => {
    if (!toDelete) return;
    await deletePublication(toDelete.id);
    setPublications((prev) => prev.filter((p) => p.id !== toDelete.id));
    setToDelete(null);
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
        <ul className="space-y-4">
          {publications.map((p) => (
            <li key={p.id}>
              <PublicationCard
                publication={p}
                onComment={(v) => handleComment(p.id, v)}
                onDelete={() => setToDelete(p)}
                onDeleteComment={(cid) => handleDeleteComment(p.id, cid)}
              />
            </li>
          ))}
        </ul>
      ) : (
        <p className="text-neutral-500 text-center py-8">Vous n&apos;avez encore rien publié.</p>
      )}

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
