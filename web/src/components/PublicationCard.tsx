import { useAuth } from "@/lib/api/authContext";
import { useProfileModal } from "@/contexts/ProfileModalContext";
import { Publication } from "@/types/publication";
import { MessageCircle } from "lucide-react";
import { useState } from "react";
import { formatTimeAgo } from "@/lib/utils";

interface PublicationCardProps {
  publication: Publication;
  onComment: (value: string) => void;
}

export default function PublicationCard({ publication, onComment }: PublicationCardProps) {
  const { user } = useAuth();
  const { showProfile } = useProfileModal();
  const [showComments, setShowComments] = useState(false);
  const [commentValue, setCommentValue] = useState("");
  const commentCount = publication.nombres_commentaires ?? 0;

  // --- DEBUG --- 
  console.log(`Publication by ${publication.auteur_username}:`, { 
    isUserLoggedIn: !!user,
    loggedInUsername: user?.username,
    isDifferentUser: user ? publication.auteur_username !== user.username : 'N/A',
    isClickable: !!user && publication.auteur_username !== user.username
  });
  // --- FIN DEBUG ---

  const handleProfileClick = () => {
    if (user && publication.auteur_username !== user.username) {
      showProfile(publication.auteur_username);
    }
  };

  const handleCommentSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (commentValue.trim()) {
      onComment(commentValue);
      setCommentValue("");
    }
  };

  return (
    <article className="bg-base-100 border border-base-300/50 rounded-xl p-4 sm:p-5 mb-4 shadow-md">
      <div className="flex items-start gap-3">
        <div className="avatar">
          <div className="w-11 rounded-full bg-base-300 overflow-hidden">
            {publication.auteur_photo_profil ? (
              <img
                src={publication.auteur_photo_profil}
                alt={publication.auteur_username}
                className="object-cover w-full h-full"
              />
            ) : (
              <span className="flex items-center justify-center h-full text-lg font-semibold">
                {publication.auteur_username.charAt(0).toUpperCase()}
              </span>
            )}
          </div>
        </div>

        <div className="flex-1">
          <div className="flex justify-between items-center">
            <p 
              className={`font-semibold text-base-content ${user && publication.auteur_username !== user.username ? 'cursor-pointer hover:underline' : ''}`}
              onClick={handleProfileClick}
            >
              {publication.auteur_username}
            </p>
            <p className="text-xs text-base-content/60">
              {formatTimeAgo(publication.date_publication)}
            </p>
          </div>

          {publication.texte && (
            <p className="mt-1 text-base-content/90 whitespace-pre-wrap">
              {publication.texte}
            </p>
          )}

          {publication.photo && (
            <img
              src={publication.photo}
              alt="Contenu de la publication"
              className="mt-3 rounded-lg border border-base-300/20 max-h-[600px] w-full object-cover"
            />
          )}

          {publication.video && (
            <video
              src={publication.video}
              controls
              className="mt-3 rounded-lg border border-base-300/20 max-h-[600px] w-full"
            />
          )}

          <div className="mt-4">
            <button
              onClick={() => setShowComments(!showComments)}
              className="flex items-center gap-2 text-base-content/70 hover:text-primary transition-colors"
            >
              <MessageCircle size={20} />
              <span className="text-sm font-medium">{commentCount}</span>
            </button>
          </div>

          {showComments && (
            <div className="mt-4 pt-4 border-t border-base-300/20">
              <form onSubmit={handleCommentSubmit} className="flex gap-2 mb-4">
                <input
                  type="text"
                  placeholder="Ajouter un commentaire..."
                  className="input input-bordered input-sm w-full"
                  value={commentValue}
                  onChange={(e) => setCommentValue(e.target.value)}
                />
                <button
                  type="submit"
                  className="btn btn-primary btn-sm"
                  disabled={!commentValue.trim()}
                >
                  Envoyer
                </button>
              </form>

              <div className="space-y-3">
                {publication.commentaires.length > 0 ? (
                  publication.commentaires.map((c) => (
                    <div key={c.id} className="flex items-start gap-2 text-sm">
                      <div className="avatar">
                        <div className="w-8 rounded-full bg-base-200 overflow-hidden flex items-center justify-center">
                          {c.auteur_photo_profil ? (
                            <img
                              src={c.auteur_photo_profil}
                              alt={c.auteur_username}
                              className="object-cover w-full h-full"
                            />
                          ) : (
                            <span className="text-xs font-semibold">
                              {c.auteur_username.charAt(0).toUpperCase()}
                            </span>
                          )}
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
                    Aucun commentaire pour le moment.
                  </p>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </article>
  );
}
