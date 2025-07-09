import { useState } from "react";
import { User } from "@/types/auth";
import Image from "next/image";
import { useAuth } from "@/lib/api/authContext";
import { envoyerDemande } from "@/lib/api/mentorat";
import { toast } from "@/components/ui/toast";
import Link from "next/link";

interface UserCardProps {
  user: User;
}

export default function UserCard({ user }: UserCardProps) {
  const { user: currentUser } = useAuth();
  const [sent, setSent] = useState(false);

  const canRequest = currentUser?.role === "ETUDIANT" && user.role === "ALUMNI";

  const sendRequest = async () => {
    try {
      await envoyerDemande(user.username);
      setSent(true);
      toast.success("Demande envoyée");
    } catch {
      toast.error("Erreur lors de l'envoi");
    }
  };

  return (
    <div className="card bg-base-100 shadow-sm">
      <div className="card-body flex items-center gap-4">
        <div className="avatar">
          <div className="w-12 rounded-full bg-base-200 overflow-hidden">
            {user.photo_profil ? (
              <Image src={user.photo_profil} alt={user.username} width={48} height={48} unoptimized />
            ) : (
              <span className="flex items-center justify-center w-full h-full font-semibold">
                {user.username.charAt(0).toUpperCase()}
              </span>
            )}
          </div>
        </div>
        <Link href={`/profile/${user.username}`} className="flex-grow">
          <div>
            <h2 className="font-semibold hover:underline">
              {user.prenom} {user.nom}
            </h2>
            <p className="text-sm opacity-70">
              @{user.username} - {user.role}
            </p>
          </div>
        </Link>
        {canRequest && (
          <button
            className="btn btn-sm ml-auto"
            onClick={sendRequest}
            disabled={sent}
          >
            {sent ? "Envoyée" : "Demander"}
          </button>
        )}
      </div>
    </div>
  );
}
