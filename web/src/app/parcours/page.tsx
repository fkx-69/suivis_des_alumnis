"use client";
import { useEffect, useState } from "react";
import {
  fetchParcoursAcademiques,
  fetchParcoursProfessionnels,
} from "@/lib/api/parcours";
import ParcoursAcademiqueSection from "@/components/profile/ParcoursAcademiqueSection";
import ParcoursProfessionnelSection from "@/components/profile/ParcoursProfessionnelSection";
import { ParcoursAcademique, ParcoursProfessionnel } from "@/types/parcours";

export default function ParcoursPage() {
  const [acad, setAcad] = useState<ParcoursAcademique[]>([]);
  const [pro, setPro] = useState<ParcoursProfessionnel[]>([]);

  const refresh = () => {
    fetchParcoursAcademiques().then(setAcad);
    fetchParcoursProfessionnels().then(setPro);
  };

  useEffect(() => {
    refresh();
  }, []);

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Mon Parcours</h1>
      <ParcoursAcademiqueSection items={acad} onChanged={refresh} />
      <ParcoursProfessionnelSection items={pro} onChanged={refresh} />
    </main>
  );
}
