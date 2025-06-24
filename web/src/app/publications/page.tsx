"use client";
import { useEffect, useState } from "react";
import {
  fetchPublications,
  createPublication,
  addComment,
} from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import { Input } from "@/components/ui/Input";
import PublicationCard from "@/components/PublicationCard";

export default function PublicationsPage() {
  const [publications, setPublications] = useState<Publication[]>([]);
  const [texte, setTexte] = useState("");

  useEffect(() => {
    fetchPublications().then(setPublications);
  }, []);

  const handleCreate = async () => {
    if (!texte.trim()) return;
    const data = new FormData();
    data.append("texte", texte);
    const pub = await createPublication(data);
    setPublications((prev) => [pub, ...prev]);
    setTexte("");
  };

  const handleComment = async (id: number, value: string) => {
    if (!value.trim()) return;
    const pub = await addComment(id, value);
    setPublications((prev) => prev.map((p) => (p.id === id ? pub : p)));
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Publications</h1>
      <div className="flex gap-2">
        <Input
          className="flex-1"
          placeholder="Exprimez-vous..."
          value={texte}
          onChange={(e) => setTexte(e.target.value)}
        />
        <button className="btn btn-primary" onClick={handleCreate}>
          Publier
        </button>
      </div>
      <ul className="divide-y divide-base-300">
        {publications.map((p) => (
          <li key={p.id}>
            <PublicationCard
              publication={p}
              onComment={(v) => handleComment(p.id, v)}
            />
          </li>
        ))}
      </ul>
    </main>
  );
}
