import { Publication } from "@/types/publication";
import { formatTimeAgo } from "@/lib/utils";
import { X } from "lucide-react";
import Image from "next/image";

interface PublicationModalProps {
  publication: Publication | null;
  onClose: () => void;
}

export default function PublicationModal({ publication, onClose }: PublicationModalProps) {
  if (!publication) {
    return null;
  }

  const avatarUrl = publication.auteur_photo_profil 
    ? publication.auteur_photo_profil 
    : `https://ui-avatars.com/api/?name=${publication.auteur_username}&background=random`;

  return (
    <div className={`modal ${publication ? 'modal-open' : ''}`}>
      <div className="modal-box w-11/12 max-w-3xl relative">
        <button onClick={onClose} className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2 z-10">
          <X size={24} />
        </button>
        
        <div className="flex items-center gap-3 mb-4">
          <div className="avatar">
              <div className="w-10 h-10 rounded-full">
                  <Image src={avatarUrl} alt={`Avatar de ${publication.auteur_username}`} width={40} height={40} unoptimized />
              </div>
          </div>
          <div>
            <p className="font-bold text-base-content">{publication.auteur_username}</p>
            <p className="text-sm text-base-content/70">{formatTimeAgo(publication.date_publication)}</p>
          </div>
        </div>

        <div className="space-y-4 max-h-[70vh] overflow-y-auto pr-2">
          {publication.texte && <p className="text-base-content/90 whitespace-pre-wrap">{publication.texte}</p>}
          
          {publication.photo && (
            <figure className="mt-2">
              <Image src={publication.photo} alt="Image de la publication" width={800} height={600} className="w-full h-auto rounded-lg object-contain" unoptimized />
            </figure>
          )}

          {publication.video && (
            <figure className="mt-2">
               <video src={publication.video} controls className="w-full h-auto rounded-lg" />
            </figure>
          )}
        </div>
      </div>
      <form method="dialog" className="modal-backdrop">
        <button onClick={onClose}>close</button>
      </form>
    </div>
  );
}
