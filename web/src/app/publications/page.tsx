"use client";
import { useEffect, useState } from "react";
import {
  fetchPublications,
  createPublication,
  addComment,
  deletePublication,
  deleteComment,
} from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import PublicationCard from "@/components/PublicationCard";
import AddPublicationModal from "@/components/AddPublicationModal";
import PublicationModal from "@/components/PublicationModal";
import { Plus } from "lucide-react";
import ConfirmModal from "@/components/ConfirmModal";

export default function PublicationsPage() {
  const [publications, setPublications] = useState<Publication[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedPublication, setSelectedPublication] = useState<Publication | null>(null);
  const [toDelete, setToDelete] = useState<Publication | null>(null);

  useEffect(() => {
    fetchPublications().then(setPublications);
  }, []);

  const handleCreate = async (formData: FormData) => {
    const pub = await createPublication(formData);
    setPublications((prev) => [pub, ...prev]);
  };

  const handleComment = async (id: number, value: string) => {
    if (!value.trim()) return;
    const pub = await addComment(id, value);
    setPublications((prev) =>
      prev.map((p) => (p.id === id ? { ...p, ...pub } : p))
    );
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

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4 relative min-h-screen">
      <h1 className="text-2xl font-semibold">Publications</h1>
      
      <ul className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {publications.map((p) => (
          <li key={p.id}>
            <PublicationCard
              publication={p}
              onComment={(v) => handleComment(p.id, v)}
              onCardClick={() => setSelectedPublication(p)}
              onDelete={() => setToDelete(p)}
              onDeleteComment={(cid) => handleDeleteComment(p.id, cid)}
            />
          </li>
        ))}
      </ul>

      <AddPublicationModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onPublish={handleCreate}
      />

      <PublicationModal
        publication={selectedPublication}
        onClose={() => setSelectedPublication(null)}
      />

      {toDelete && (
        <ConfirmModal
          title="Supprimer la publication"
          message="Cette action est irreversible."
          confirmText="Supprimer"
          cancelText="Annuler"
          onConfirm={confirmDelete}
          onCancel={() => setToDelete(null)}
        />
      )}

      <button
        onClick={() => setIsModalOpen(true)}
        className="btn btn-primary btn-circle fixed bottom-10 right-10 shadow-lg z-50"
        aria-label="Ajouter une publication"
      >
        <Plus size={28} />
      </button>
    </main>
  );
}
