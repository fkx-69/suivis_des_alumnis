"use client";
import { useEffect, useState } from "react";
import { fetchMesDemandes, repondreDemande } from "@/lib/api/mentorat";
import { DemandeMentorat } from "@/types/mentorat";
import { useAuth } from "@/lib/api/authContext";

export default function MentoratPage() {
  const { user } = useAuth();
  const [demandes, setDemandes] = useState<DemandeMentorat[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchMesDemandes()
      .then(setDemandes)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  const handleRepondre = async (
    id: number,
    statut: "acceptee" | "refusee"
  ) => {
    try {
      const updated = await repondreDemande(id, statut);
      setDemandes((prev) => prev.map((d) => (d.id === id ? updated : d)));
    } catch (err) {
      console.error(err);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center p-4">
        <span className="loading loading-spinner" />
      </div>
    );
  }

  if (error) {
    return <div className="alert alert-error">{error}</div>;
  }

  return (
    <main className="p-4 space-y-4">
      <h1 className="text-2xl font-semibold">Mes demandes de mentorat</h1>
      <ul className="space-y-2">
        {demandes.map((d) => (
          <li key={d.id} className="p-3 bg-base-200 rounded-md space-y-1">
            <p>
              <span className="font-semibold">Etudiant:</span> {d.etudiant_username}
            </p>
            <p>
              <span className="font-semibold">Mentor:</span> {d.mentor_username}
            </p>
            <p>
              <span className="font-semibold">Statut:</span> {d.statut}
            </p>
            {d.motif_refus && (
              <p className="text-sm opacity-80">Motif: {d.motif_refus}</p>
            )}
            {user?.role === "ALUMNI" &&
              d.statut === "en_attente" &&
              d.mentor === user.id && (
                <div className="flex gap-2 pt-2">
                  <button
                    className="btn btn-sm btn-primary"
                    onClick={() => handleRepondre(d.id, "acceptee")}
                  >
                    Accepter
                  </button>
                  <button
                    className="btn btn-sm"
                    onClick={() => handleRepondre(d.id, "refusee")}
                  >
                    Refuser
                  </button>
                </div>
              )}
          </li>
        ))}
      </ul>
    </main>
  );
}
