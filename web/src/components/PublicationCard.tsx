import { Publication } from "@/types/publication";
import { Input } from "@/components/ui/Input";
import { useState } from "react";

interface PublicationCardProps {
  publication: Publication;
  onComment: (value: string) => void;
}

export default function PublicationCard({
  publication,
  onComment,
}: PublicationCardProps) {
  const [value, setValue] = useState("");

  return (
    <div className="border-b border-base-300 p-4 flex gap-3">
      <div className="avatar placeholder">
        <div className="w-10 rounded-full bg-neutral text-neutral-content flex items-center justify-center">
          {publication.auteur_username.charAt(0).toUpperCase()}
        </div>
      </div>
      <div className="flex-1">
        <p className="font-semibold">{publication.auteur_username}</p>
        {publication.texte && (
          <p className="mt-2 whitespace-pre-wrap">{publication.texte}</p>
        )}
        <div className="mt-3 space-y-2">
          {publication.commentaires.map((c) => (
            <div key={c.id} className="pl-3 border-l border-base-300 text-sm">
              <span className="font-semibold">{c.auteur_username}</span>{" "}
              {c.contenu}
            </div>
          ))}
          <div className="flex gap-2">
            <Input
              className="flex-1"
              placeholder="Commenter..."
              value={value}
              onChange={(e) => setValue(e.target.value)}
            />
            <button
              className="btn btn-sm"
              onClick={() => {
                onComment(value);
                setValue("");
              }}
            >
              Envoyer
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
