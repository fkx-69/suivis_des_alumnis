"use client";
import { useEffect, useState } from "react";
import {
  fetchPublications,
  createPublication,
  addComment,
} from "@/lib/api/publication";
import { Publication } from "@/types/publication";
import { Input } from "@/components/ui/Input";

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
      <ul className="space-y-4">
        {publications.map((p) => (
          <li key={p.id} className="p-3 bg-base-200 rounded-md space-y-2">
            <p className="font-semibold">{p.auteur_username}</p>
            {p.texte && <p>{p.texte}</p>}
            <div className="space-y-1">
              {p.commentaires.map((c) => (
                <div key={c.id} className="pl-2 border-l border-base-300">
                  <p className="text-sm">
                    <span className="font-semibold">{c.auteur_username}</span> {" "}
                    {c.contenu}
                  </p>
                </div>
              ))}
              <CommentForm onAdd={(v) => handleComment(p.id, v)} />
            </div>
          </li>
        ))}
      </ul>
    </main>
  );
}

function CommentForm({ onAdd }: { onAdd: (value: string) => void }) {
  const [value, setValue] = useState("");
  return (
    <div className="flex gap-2 mt-2">
      <Input
        className="flex-1"
        placeholder="Commenter..."
        value={value}
        onChange={(e) => setValue(e.target.value)}
      />
      <button
        className="btn btn-sm"
        onClick={() => {
          onAdd(value);
          setValue("");
        }}
      >
        Envoyer
      </button>
    </div>
  );
}
