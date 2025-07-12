"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import { useParams } from "next/navigation";
import { UserProfile, fetchUserProfile } from "@/lib/api/users";
import { Publication } from "@/types/publication";
import { fetchUserPublications } from "@/lib/api/publication";
import PublicationCard from "@/components/PublicationCard";
import { useAuth } from "@/lib/api/authContext";
import { envoyerDemande } from "@/lib/api/mentorat";
import { toast } from "@/components/ui/toast";
import Link from "next/link";

export default function UserProfilePage() {
  const params = useParams();
  const username = params.username as string;
  const { user: currentUser } = useAuth();

  const [user, setUser] = useState<UserProfile | null>(null);
  const [publications, setPublications] = useState<Publication[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (username) {
      const fetchData = async () => {
        try {
          setLoading(true);
          const [userData, publicationsData] = await Promise.all([
            fetchUserProfile(username),
            fetchUserPublications(username),
          ]);
          setUser(userData);
          setPublications(publicationsData);
        } catch (err) {
          setError(
            "Impossible de charger le profil. L'utilisateur n'existe peut-être pas."
          );
          console.error(err);
        } finally {
          setLoading(false);
        }
      };

      fetchData();
    }
  }, [username]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );
  }

  if (error) {
    return <div className="text-center py-10 text-red-500">{error}</div>;
  }

  if (!user) {
    return <div className="text-center py-10">Utilisateur non trouvé.</div>;
  }

  const handleMentoratRequest = async () => {
    try {
      await envoyerDemande(user.username);
      toast.success(`Demande de mentorat envoyée à ${user.prenom}.`);
    } catch (error) {
      console.error("Erreur lors de l'envoi de la demande de mentorat:", error);
    }
  };

  const showMentoratButton =
    currentUser?.role.toUpperCase() === "ETUDIANT" &&
    user.role.toUpperCase() === "ALUMNI";

  return (
    <div className="container mx-auto p-4 md:p-8">
      <div className="bg-base-100 rounded-2xl shadow-lg p-8 mb-8">
        <div className="flex flex-col md:flex-row items-center md:items-start gap-8">
          <div className="avatar w-32 h-32 rounded-full overflow-hidden border-4 border-primary">
            <Image
              src={
                user.photo_profil ||
                `https://ui-avatars.com/api/?name=${user.prenom}+${user.nom}&background=random`
              }
              alt={user.username}
              width={128}
              height={128}
              className="object-cover w-full h-full"
            />
          </div>
          <div className="text-center md:text-left">
            <h1 className="text-3xl font-bold">
              {user.prenom} {user.nom}
            </h1>
            <p className="text-lg text-neutral-500">@{user.username}</p>
            <p className="mt-4 text-base">{user.biographie}</p>
            <span className="badge badge-primary mt-2">{user.role}</span>
            <div className="mt-6 flex w-full items-center gap-x-2">
              <Link
                href={`/discussions/${user.username}`}
                className="btn btn-primary flex-1"
              >
                Contacter
              </Link>
              {showMentoratButton && (
                <button
                  onClick={handleMentoratRequest}
                  className="btn btn-secondary flex-1"
                >
                  Mentor
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      <div>
        <h2 className="text-2xl font-bold mb-6">Publications</h2>
        {publications.length > 0 ? (
          <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-6">
            {publications.map((p) => (
              <li key={p.id}>
                <PublicationCard publication={p} onComment={() => {}} />
              </li>
            ))}
          </ul>
        ) : (
          <p>Cet utilisateur n&apos;a aucune publication.</p>
        )}
      </div>
    </div>
  );
}
