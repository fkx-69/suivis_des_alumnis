"use client";
import { useEffect, useState } from "react";
import { fetchSituationStats, fetchDomaineStats } from "@/lib/api/statistiques";
import { fetchFilieres } from "@/lib/api/filiere";
import { SituationProStat, DomaineStat } from "@/types/stats";
import { Filiere } from "@/lib/api/filiere";
import { jobBySector } from "@/lib/constants";
import {
  Chart as ChartJS,
  ArcElement,
  Tooltip,
  Legend,
  CategoryScale,
  LinearScale,
  BarElement,
} from "chart.js";
import { Pie, Bar } from "react-chartjs-2";

ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement);

// Ajoute un mapping pour les labels lisibles
const situationLabels: Record<string, string> = {
  emploi: "En emploi",
  stage: "En stage",
  chomage: "En recherche d'emploi",
  formation: "En formation",
  autre: "Autre situation",
};

// Fonction pour obtenir le label d'un domaine
const getDomaineLabel = (domaine: string): string => {
  for (const sector of Object.values(jobBySector)) {
    if (sector[domaine as keyof typeof sector]) {
      return sector[domaine as keyof typeof sector];
    }
  }
  return domaine; // Retourne le domaine original si pas trouvé
};

export default function StatistiquesPage() {
  const [stats, setStats] = useState<SituationProStat[]>([]);
  const [domaineStats, setDomaineStats] = useState<DomaineStat[]>([]);
  const [filieres, setFilieres] = useState<Filiere[]>([]);
  const [selectedFiliere, setSelectedFiliere] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchSituationStats().then(setStats);
    fetchFilieres().then(setFilieres);
  }, []);

  useEffect(() => {
    if (selectedFiliere) {
      fetchDomaineStats(selectedFiliere).then(setDomaineStats);
    } else {
      setDomaineStats([]);
    }
  }, [selectedFiliere]);

  const situationData = {
    labels: stats.map((s) => situationLabels[s.situation] || s.situation),
    datasets: [
      {
        label: "Alumnis",
        data: stats.map((s) => s.count),
        backgroundColor: [
          "#60a5fa", // bleu
          "#fbbf24", // jaune
          "#34d399", // vert
          "#f87171", // rouge
          "#a78bfa", // violet
          "#f472b6", // rose
        ],
        borderWidth: 2,
      },
    ],
  };

  const domaineData = {
    labels: domaineStats.map((d) => getDomaineLabel(d.domaine)),
    datasets: [
      {
        label: "Nombre d'emplois",
        data: domaineStats.map((d) => d.count),
        backgroundColor: "#3b82f6",
        borderColor: "#1d4ed8",
        borderWidth: 1,
      },
    ],
  };

  return (
    <main className="mx-auto max-w-6xl px-4 py-8 space-y-8">
      <h1 className="text-3xl font-bold text-center mb-6">Statistiques des Alumni</h1>
      
      {/* Section Situations Professionnelles */}
      <section className="bg-base-100 rounded-2xl shadow-lg p-6">
        <h2 className="text-2xl font-semibold mb-6 text-center">Répartition par situation professionnelle</h2>
        <div className="flex flex-col md:flex-row gap-8 items-center justify-center">
          <div className="w-full md:w-1/2 flex justify-center">
            <Pie
              data={situationData}
              options={{
                plugins: {
                  legend: {
                    display: true,
                    position: "bottom" as const,
                    labels: {
                      font: { size: 16 },
                    },
                  },
                },
                responsive: true,
                maintainAspectRatio: false,
              }}
              height={260}
            />
          </div>
          <div className="w-full md:w-1/2 flex flex-col gap-3">
            <ul className="space-y-2">
              {stats.map((s, i) => (
                <li
                  key={s.situation}
                  className="flex items-center justify-between bg-base-200 rounded-lg px-4 py-2 shadow-sm"
                >
                  <span className="flex items-center gap-2">
                    <span
                      className={`inline-block w-3 h-3 rounded-full mr-2`}
                      style={{ backgroundColor: situationData.datasets[0].backgroundColor[i % situationData.datasets[0].backgroundColor.length] }}
                    ></span>
                    <span className="font-medium">
                      {situationLabels[s.situation] || s.situation}
                    </span>
                  </span>
                  <span className="badge badge-lg badge-outline font-bold text-base">
                    {s.count}
                  </span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* Section Domaines par Filière */}
      <section className="bg-base-100 rounded-2xl shadow-lg p-6">
        <h2 className="text-2xl font-semibold mb-6 text-center">Répartition des emplois par domaine</h2>
        
        {/* Sélecteur de filière */}
        <div className="mb-6 flex justify-center">
          <div className="form-control w-full max-w-md">
            <label className="label">
              <span className="label-text">Sélectionner une filière</span>
            </label>
            <select
              className="select select-primary w-full"
              value={selectedFiliere || ""}
              onChange={(e) => setSelectedFiliere(e.target.value ? Number(e.target.value) : null)}
            >
              <option value="">Toutes les filières</option>
              {filieres.map((filiere) => (
                <option key={filiere.id} value={filiere.id}>
                  {filiere.nom_complet}
                </option>
              ))}
            </select>
          </div>
        </div>

        {selectedFiliere && domaineStats.length > 0 ? (
          <div className="flex flex-col lg:flex-row gap-8">
            <div className="w-full lg:w-2/3">
              <Bar
                data={domaineData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      display: false,
                    },
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      ticks: {
                        stepSize: 1,
                      },
                    },
                  },
                }}
                height={300}
              />
            </div>
            <div className="w-full lg:w-1/3">
              <h3 className="text-lg font-semibold mb-4">Détail par domaine</h3>
              <ul className="space-y-2">
                {domaineStats.map((d) => (
                  <li
                    key={d.domaine}
                    className="flex items-center justify-between bg-base-200 rounded-lg px-4 py-2 shadow-sm"
                  >
                    <span className="font-medium">
                      {getDomaineLabel(d.domaine)}
                    </span>
                    <span className="badge badge-primary badge-lg font-bold">
                      {d.count}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        ) : selectedFiliere ? (
          <div className="text-center py-8">
            <p className="text-base-content/70">Aucune donnée disponible pour cette filière.</p>
          </div>
        ) : (
          <div className="text-center py-8">
            <p className="text-base-content/70">Sélectionnez une filière pour voir les statistiques de domaines.</p>
          </div>
        )}
      </section>
    </main>
  );
}
