"use client";
import { useEffect, useState } from "react";
import {
  fetchPublications,
  createPublication,
  addComment,
} from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import PublicationCard from "@/components/PublicationCard";
import AddPublicationModal from "@/components/AddPublicationModal";
import { Plus } from "lucide-react";

export default function PublicationsPage() {
  const [publications, setPublications] = useState<Publication[]>([]);
  const [isModalOpen, setIsModalOpen] = useState(false);

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

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4 relative min-h-screen">
      <h1 className="text-2xl font-semibold">Publications</h1>
      
      <ul>
        {publications.map((p) => (
          <li key={p.id}>
            <PublicationCard
              publication={p}
              onComment={(v) => handleComment(p.id, v)}
            />
          </li>
        ))}
      </ul>

      <AddPublicationModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onPublish={handleCreate}
      />

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
