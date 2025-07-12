"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { fetchMesDemandes, repondreDemande } from "@/lib/api/mentorat";
import { DemandeMentorat } from "@/types/mentorat";
import { useAuth } from "@/lib/api/authContext";
import { fetchUserProfile, UserProfile } from "@/lib/api/users";

// Interface pour combiner la demande de mentorat avec le profil de l'autre utilisateur
interface DemandeMentoratWithProfile extends DemandeMentorat {
  profile: UserProfile;
}

export default function MentoratRequests() {
  const { user } = useAuth();
  const [demandes, setDemandes] = useState<DemandeMentoratWithProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;

    const getDemandes = async () => {
      try {
        const rawDemandes = await fetchMesDemandes();

        // Pour chaque demande, récupérer le profil de l'autre utilisateur
        const demandesWithProfiles = await Promise.all(
          rawDemandes.map(async (demande) => {
            const otherUsername =
              user.role?.toUpperCase() === "ALUMNI"
                ? demande.etudiant_username
                : demande.mentor_username;
            const profile = await fetchUserProfile(otherUsername);
            return { ...demande, profile };
          })
        );

        setDemandes(demandesWithProfiles);
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    getDemandes();
  }, [user]);

  const handleRepondre = async (id: number, statut: "acceptee" | "refusee") => {
    try {
      const updated = await repondreDemande(id, statut);
      // Mettre à jour uniquement le statut de la demande dans l'état local
      setDemandes((prev) =>
        prev.map((d) => (d.id === id ? { ...d, statut: updated.statut } : d))
      );
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

  const getStatusBadge = (statut: string) => {
    switch (statut) {
      case "acceptee":
        return "badge-success";
      case "refusee":
        return "badge-error";
      case "en_attente":
      default:
        return "badge-warning";
    }
  };

  const cardTitle =
    user?.role?.toUpperCase() === "ALUMNI"
      ? "Demandes de mentorat"
      : "Mon Mentor";

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold">{cardTitle}</h2>
      {demandes.length > 0 ? (
        <div className="space-y-4">
          {demandes.map((demande) => {
            const photoUrl = demande.profile.photo_profil
              ? demande.profile.photo_profil
              : `https://ui-avatars.com/api/?name=${demande.profile.prenom}+${demande.profile.nom}&background=random`;

            return (
              <div key={demande.id} className="card bg-base-100 transition-all">
                <div className="card-body p-4">
                  <div className="flex items-center space-x-4">
                    <div className="avatar">
                      <div className="w-16 h-16 rounded-full ring ring-primary ring-offset-base-100 ring-offset-2">
                        <Image
                          src={photoUrl}
                          alt={`Photo de ${demande.profile.prenom}`}
                          width={64}
                          height={64}
                        />
                      </div>
                    </div>
                    <div>
                      <h3 className="card-title text-lg font-bold">{`${demande.profile.prenom} ${demande.profile.nom}`}</h3>
                      <p className="text-sm text-base-content/70">
                        @{demande.profile.username}
                      </p>
                    </div>
                  </div>

                  <div className="divider my-3"></div>

                  <div className="flex justify-between items-center">
                    <h3 className="font-bold">Statut : </h3>
                    <span
                      className={`badge ${getStatusBadge(demande.statut)} capitalize`}
                    >
                      {demande.statut === "acceptee"
                        ? "Accepté"
                        : demande.statut === "refusee"
                          ? "Refusé"
                          : "En attente"}
                    </span>

                    {user?.role?.toUpperCase() === "ALUMNI" &&
                      demande.statut === "en_attente" &&
                      demande.mentor === user.id && (
                        <div className="flex gap-2">
                          <button
                            className="btn btn-sm btn-primary"
                            onClick={() =>
                              handleRepondre(demande.id, "acceptee")
                            }
                          >
                            Accepter
                          </button>
                          <button
                            className="btn btn-sm btn-ghost"
                            onClick={() =>
                              handleRepondre(demande.id, "refusee")
                            }
                          >
                            Refuser
                          </button>
                        </div>
                      )}
                  </div>
                  {demande.statut === "refusee" && demande.motif_refus && (
                    <p className="text-xs italic opacity-80 mt-2">
                      Motif du refus: {demande.motif_refus}
                    </p>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <p className="text-base-content/70 italic">
          {user?.role?.toUpperCase() === "ALUMNI"
            ? "Vous n'avez aucune nouvelle demande de mentorat."
            : "Vous n'avez pas encore de mentorat en cours."}
        </p>
      )}
    </div>
  );
}
