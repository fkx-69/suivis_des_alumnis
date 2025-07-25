import { useAuth } from "@/lib/api/authContext";
import { useProfileModal } from "@/contexts/ProfileModalContext";
import { Publication } from "@/types/publication";
import { MessageCircle, Trash2 } from "lucide-react";
import { useState } from "react";
import Image from "next/image";
import { formatTimeAgo } from "@/lib/utils";

interface PublicationCardProps {
  publication: Publication;
  onComment: (value: string) => void;
  onCardClick?: () => void;
  onDelete?: () => void;
  onDeleteComment?: (commentId: number) => void;
}

export default function PublicationCard({
  publication,
  onComment,
  onCardClick,
  onDelete,
  onDeleteComment,
}: PublicationCardProps) {
  const { user } = useAuth();
  const { showProfile } = useProfileModal();
  const [showComments, setShowComments] = useState(false);
  const [commentValue, setCommentValue] = useState("");
  const commentCount = publication.nombres_commentaires ?? 0;

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
    <article
      className={`relative bg-base-100 border border-base-300/50 rounded-xl p-4 sm:p-5 mb-4 shadow-md flex flex-col ${onCardClick ? "cursor-pointer hover:border-primary/50 transition-colors" : ""}`}
      onClick={onCardClick}
    >
      {user?.username === publication.auteur_username && onDelete && (
        <button
          className="btn btn-xs  btn-ghost text-error absolute top-2 right-2 z-10"
          onClick={(e) => {
            e.stopPropagation();
            onDelete();
          }}
        >
          <Trash2 size={16} />
        </button>
      )}
      {/* En-tête de la publication */}
      <div className="flex items-start gap-3">
        <div className="avatar">
          <div className="w-11 rounded-full bg-base-300 overflow-hidden">
            {publication.auteur_photo_profil ? (
              <Image
                src={publication.auteur_photo_profil}
                alt={publication.auteur_username}
                width={44}
                height={44}
                className="object-cover w-full h-full"
                sizes="132px"
              />
            ) : (
              <span className="flex items-center justify-center h-full text-lg font-semibold">
                {publication.auteur_username.charAt(0).toUpperCase()}
              </span>
            )}
          </div>
        </div>
        <div className="flex-1">
          <p
            className={`font-semibold text-base-content ${user && publication.auteur_username !== user.username ? "cursor-pointer hover:underline" : ""}`}
            onClick={(e) => {
              e.stopPropagation();
              handleProfileClick();
            }}
          >
            {publication.auteur_username}
          </p>
          <p className="text-xs text-base-content/60">
            {formatTimeAgo(publication.date_publication)}
          </p>
        </div>
      </div>

      {/* Contenu de la publication */}
      <div
        className={`mt-4 flex-1 ${!publication.photo && !publication.video ? "flex items-center" : ""}`}
      >
        <div className="min-h-[3rem]">
          {publication.texte && (
            <p className="text-base-content/90 line-clamp-2">
              {publication.texte}
            </p>
          )}
        </div>

        {publication.photo && (
          <div className="mt-3 rounded-lg overflow-hidden border border-base-300/20 h-64 sm:h-80">
            <Image
              src={publication.photo}
              alt="Contenu de la publication"
              width={640}
              height={320}
              className="w-full h-full object-cover"
            />
          </div>
        )}

        {publication.video && (
          <div className="mt-3 rounded-lg overflow-hidden border border-base-300/20">
            <video
              src={publication.video}
              controls
              className="w-full h-auto max-h-[400px]"
            />
          </div>
        )}
      </div>

      {/* Actions et commentaires */}
      <div className="mt-4" onClick={(e) => e.stopPropagation()}>
        <button
          onClick={() => setShowComments(!showComments)}
          className="flex items-center gap-2 text-base-content/70 hover:text-primary transition-colors"
        >
          <MessageCircle size={20} />
          <span className="text-sm font-medium">{commentCount}</span>
        </button>

        {showComments && (
          <div className="mt-4 pt-3 border-t border-base-300/20">
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
                          <Image
                            src={c.auteur_photo_profil}
                            alt={c.auteur_username}
                            width={32}
                            height={32}
                            className="object-cover w-full h-full"
                          />
                        ) : (
                          <span className="text-xs font-semibold">
                            {c.auteur_username.charAt(0).toUpperCase()}
                          </span>
                        )}
                      </div>
                    </div>
                    <div className="bg-base-200/60 rounded-lg px-3 py-2 w-full flex justify-between items-start">
                      <span className="font-bold mr-2">
                        {c.auteur_username}
                      </span>
                      <span className="flex-1 break-words">{c.contenu}</span>
                      {onDeleteComment &&
                        user &&
                        (user.username === c.auteur_username ||
                          user.username === publication.auteur_username) && (
                          <button
                            className="btn btn-ghost btn-xs text-error"
                            onClick={() => onDeleteComment(c.id)}
                          >
                            <Trash2 size={14} />
                          </button>
                        )}
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
    </article>
  );
}
