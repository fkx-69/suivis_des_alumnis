"use client";
import { useEffect, useState } from "react";
import { fetchSituationStats } from "@/lib/api/statistiques";
import { SituationProStat } from "@/types/stats";

export default function StatistiquesPage() {
  const [stats, setStats] = useState<SituationProStat[]>([]);

  useEffect(() => {
    fetchSituationStats().then(setStats);
  }, []);

  return (
    <main className="p-4 space-y-2">
      <h1 className="text-2xl font-semibold">Statistiques</h1>
      <ul className="space-y-1">
        {stats.map((s) => (
          <li key={s.situation} className="p-2 bg-base-200 rounded-md">
            {s.situation}: {s.count}
          </li>
        ))}
      </ul>
    </main>
  );
}
