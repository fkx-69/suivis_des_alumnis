import React from "react";
import { motion } from "framer-motion";
import Image from "next/image";
import Link from "next/link";
import { useAuth } from "@/lib/api/authContext";
import { envoyerDemande } from "@/lib/api/mentorat";
import { toast } from "@/components/ui/toast";
import ReportUserModal from "./ReportUserModal";

interface UserProfile {
  id: number;
  username: string;
  nom: string;
  prenom: string;
  photo_profil: string;
  biographie: string;
  role: "alumni" | "etudiant" | "enseignant";
}

interface ExternalProfileModalProps {
  user: UserProfile;
  onClose: () => void;
}

export default function ExternalProfileModal({
  user,
  onClose,
}: ExternalProfileModalProps) {
  const { user: currentUser } = useAuth();
  const [reportOpen, setReportOpen] = React.useState(false);

  const handleMentoratRequest = async () => {
    try {
      await envoyerDemande(user.username);
      toast.success("Votre demande de mentorat a bien été envoyée.");
      onClose();
    } catch (error: any) {
      if (error?.response?.status === 500) {
        toast.error("Vous avez déjà fait une demande à cet alumni.");
      } else {
        toast.error("Erreur lors de l'envoi de la demande de mentorat.");
      }
    }
  };

  const showMentoratButton =
    currentUser?.role === "etudiant".toUpperCase() &&
    user.role === "alumni".toUpperCase();

  React.useEffect(() => {
    const handleEsc = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        onClose();
      }
    };
    window.addEventListener("keydown", handleEsc);

    return () => {
      window.removeEventListener("keydown", handleEsc);
    };
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      onClick={onClose}
    >
      <motion.div
        role="dialog"
        aria-modal="true"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.95 }}
        transition={{ duration: 0.2 }}
        className="relative w-full max-w-sm bg-base-100 rounded-2xl p-8 shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >

        <div className="flex flex-col items-center text-center">
          <Link href={`/profile/${user.username}`} onClick={onClose}>
            <div className="mb-3">
              <Image
                className="mb-1 w-28 h-28 rounded-full justify-self-center shadow-lg object-cover"
                src={
                  user.photo_profil ||
                  `https://ui-avatars.com/api/?name=${user.prenom}+${user.nom}&background=random`
                }
                alt={`Profil de ${user.prenom}`}
                width={112}
                height={112}
              />
              <span className="text-sm text-base-content/70">
                @{user.username} ({user.role})
              </span>
            </div>
            <h3 className="mb-1 text-2xl font-bold text-base-content hover:underline">
              {user.prenom} {user.nom}{" "}
            </h3>
          </Link>

          {user.biographie && (
            <p className="text-base-content/80 mt-4">{user.biographie}</p>
          )}

          <div className="mt-6 flex w-full items-center gap-x-2">
            <Link
              href={`/discussions/${user.username}`}
              className="btn btn-primary flex-1"
              onClick={onClose}
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
            <button
              onClick={() => setReportOpen(true)}
              className="btn btn-error flex-1"
            >
              Signaler
            </button>
          </div>
        </div>
        {reportOpen && (
          <ReportUserModal
            userId={user.id}
            onClose={() => setReportOpen(false)}
          />
        )}
      </motion.div>
    </div>
  );
}
