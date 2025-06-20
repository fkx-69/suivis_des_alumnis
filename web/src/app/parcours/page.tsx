"use client";
import { useEffect, useState } from "react";
import {
  fetchParcoursAcademiques,
  fetchParcoursProfessionnels,
} from "@/lib/api/parcours";
import { ParcoursAcademique, ParcoursProfessionnel } from "@/types/parcours";

export default function ParcoursPage() {
  const [acad, setAcad] = useState<ParcoursAcademique[]>([]);
  const [pro, setPro] = useState<ParcoursProfessionnel[]>([]);

  useEffect(() => {
    fetchParcoursAcademiques().then(setAcad);
    fetchParcoursProfessionnels().then(setPro);
  }, []);

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Mon Parcours</h1>
      <div>
        <h2 className="text-xl font-semibold mb-2">Académique</h2>
        <ul className="space-y-1">
          {acad.map((p) => (
            <li key={p.id} className="bg-base-200 rounded-md p-2">
              {p.diplome} - {p.institution} ({p.annee_obtention})
            </li>
          ))}
        </ul>
      </div>
      <div>
        <h2 className="text-xl font-semibold mb-2">Professionnel</h2>
        <ul className="space-y-1">
          {pro.map((p) => (
            <li key={p.id} className="bg-base-200 rounded-md p-2">
              {p.poste} - {p.entreprise}
            </li>
          ))}
        </ul>
      </div>
    </main>
  );
}
