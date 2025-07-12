"use client";
import { useEffect, useState } from "react";
import { fetchSituationStats } from "@/lib/api/statistiques";
import { SituationProStat } from "@/types/stats";
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
} from "chart.js";
import { Pie } from "react-chartjs-2";

ChartJS.register(ArcElement, Tooltip, Legend);

export default function StatistiquesPage() {
  const [stats, setStats] = useState<SituationProStat[]>([]);

  useEffect(() => {
    fetchSituationStats().then(setStats);
  }, []);

  const data = {
    labels: stats.map((s) => s.situation),
    datasets: [
      {
        label: "Alumnis",
        data: stats.map((s) => s.count),
        backgroundColor: [
          "#93c5fd",
          "#fda4af",
          "#34d399",
          "#fcd34d",
          "#c084fc",
          "#fca5a5",
        ],
      },
    ],
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Statistiques</h1>
      <div className="card bg-base-200 p-4">
        <Pie data={data} />
      </div>
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
