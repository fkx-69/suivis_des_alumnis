"use client";
import { useEffect, useState } from "react";
import { fetchFilieres, createFiliere, deleteFiliere, Filiere } from "@/lib/api/filiere";
import { Input } from "@/components/ui/Input";

export default function FilierePage() {
  const [filieres, setFilieres] = useState<Filiere[]>([]);
  const [code, setCode] = useState("");
  const [nom, setNom] = useState("");

  useEffect(() => {
    fetchFilieres().then(setFilieres);
  }, []);

  const handleCreate = async () => {
    if (!code || !nom) return;
    const f = await createFiliere({ code, nom_complet: nom });
    setFilieres((p) => [...p, f]);
    setCode("");
    setNom("");
  };

  const handleDelete = async (id: number) => {
    await deleteFiliere(id);
    setFilieres((p) => p.filter((f) => f.id !== id));
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Filières</h1>
      <div className="flex gap-2 max-w-md">
        <Input placeholder="Code" value={code} onChange={(e) => setCode(e.target.value)} />
        <Input placeholder="Nom" value={nom} onChange={(e) => setNom(e.target.value)} />
        <button className="btn btn-primary" onClick={handleCreate}>Ajouter</button>
      </div>
      <ul className="space-y-2">
        {filieres.map((f: any) => (
          <li key={f.id} className="p-2 bg-base-200 rounded-md flex justify-between">
            <span>
              {f.code} - {f.nom_complet}
            </span>
            <button className="btn btn-xs" onClick={() => handleDelete(f.id)}>Supprimer</button>
          </li>
        ))}
      </ul>
    </main>
  );
}
