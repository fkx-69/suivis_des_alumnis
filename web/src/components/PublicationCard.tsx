// src/components/PublicationCardDaisy.tsx

import { Publication } from "@/types/publication";
import { useState } from "react";

// Helper function pour formater la date de publication
function formatTimeAgo(dateString: string): string {
  const now = new Date();
  const date = new Date(dateString);
  const secondsPast = (now.getTime() - date.getTime()) / 1000;

  if (secondsPast < 60) {
    return "à l'instant";
  }
  if (secondsPast < 3600) {
    const minutes = Math.floor(secondsPast / 60);
    return `il y a ${minutes} min`;
  }
  if (secondsPast <= 86400) {
    const hours = Math.floor(secondsPast / 3600);
    return `il y a ${hours} h`;
  }
  if (secondsPast <= 604800) {
    const days = Math.floor(secondsPast / 86400);
    if (days === 1) {
      return "hier";
    }
    return `il y a ${days} j`;
  }
  return new Intl.DateTimeFormat("fr-FR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(date);
}

interface PublicationCardProps {
  publication: Publication;
  onComment: (value: string) => void;
}

export default function PublicationCardDaisy({
  publication,
  onComment,
}: PublicationCardProps) {
  const [value, setValue] = useState("");

  const handleCommentSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (value.trim()) {
      onComment(value);
      setValue("");
    }
  };

  return (
    <div className="card w-full bg-base-100 shadow-md border border-base-300/50 mb-6">
      <div className="card-body p-5">
        <div className="flex items-center gap-4 mb-3">
          <div className="avatar placeholder">
            {/* MODIFICATION: Classes flex ajoutées pour centrer la lettre */}
            <div className="bg-neutral text-neutral-content rounded-full w-12 flex items-center justify-center">
              <span className="text-xl font-bold">
                {publication.auteur_username.charAt(0).toUpperCase()}
              </span>
            </div>
          </div>
          <div>
            <h2 className="card-title text-base font-bold">
              {publication.auteur_username}
            </h2>
            {/* MODIFICATION: Utilisation de la fonction formatTimeAgo avec la date de la publication */}
            <p className="text-xs text-base-content/60">
              {formatTimeAgo(publication.date_publication)}
            </p>
          </div>
        </div>

        {publication.texte && (
          <p className="whitespace-pre-wrap text-base-content/90">
            {publication.texte}
          </p>
        )}

        <div className="divider my-1"></div>

        <div className="space-y-3">
          <h3 className="font-semibold text-sm">
            Commentaires ({publication.commentaires.length})
          </h3>
          {publication.commentaires.length > 0 ? (
            publication.commentaires.map((c) => (
              <div key={c.id} className="flex items-start gap-2 text-sm">
                <div className="avatar placeholder">
                  {/* MODIFICATION: Classes flex ajoutées pour centrer la lettre */}
                  <div className="bg-base-300 text-base-content rounded-full w-6 flex items-center justify-center">
                    <span className="text-xs font-semibold">
                      {c.auteur_username.charAt(0).toUpperCase()}
                    </span>
                  </div>
                </div>
                <div className="bg-base-200/60 rounded-lg px-3 py-2 w-full">
                  <span className="font-bold mr-2">{c.auteur_username}</span>
                  <span>{c.contenu}</span>
                </div>
              </div>
            ))
          ) : (
            <p className="text-sm text-base-content/50 italic">
              Soyez le premier à commenter !
            </p>
          )}
        </div>

        <form onSubmit={handleCommentSubmit} className="flex gap-2 mt-4">
          <input
            type="text"
            placeholder="Ajouter un commentaire..."
            className="input input-bordered w-full"
            value={value}
            onChange={(e) => setValue(e.target.value)}
          />
          <button
            type="submit"
            className="btn btn-primary"
            disabled={!value.trim()}
          >
            Envoyer
          </button>
        </form>
      </div>
    </div>
  );
}
