"use client";

import { useState, useRef } from "react";
import { X, Image as ImageIcon, Video as VideoIcon } from "lucide-react";

interface AddPublicationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onPublish: (formData: FormData) => Promise<void>;
}

export default function AddPublicationModal({ isOpen, onClose, onPublish }: AddPublicationModalProps) {
  const [texte, setTexte] = useState("");
  const [media, setMedia] = useState<File | null>(null);
  const [mediaPreview, setMediaPreview] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (!isOpen) return null;

  const handleMediaChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setMedia(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setMediaPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!texte.trim() && !media) return;

    setIsSubmitting(true);
    const formData = new FormData();
    formData.append("texte", texte);
    if (media) {
      formData.append(media.type.startsWith("image/") ? "photo" : "video", media);
    }

    await onPublish(formData);

    // Reset state and close
    setIsSubmitting(false);
    setTexte("");
    setMedia(null);
    setMediaPreview(null);
    onClose();
  };

  const mediaType = media?.type.startsWith("video/") ? "video" : "image";

  return (
    <div className="modal modal-open modal-bottom sm:modal-middle">
      <div className="modal-box relative">
        <button onClick={onClose} className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        <h3 className="font-bold text-lg mb-4">Créer une publication</h3>

        <form onSubmit={handleSubmit} className="space-y-4">
          <textarea
            className="textarea textarea-bordered w-full h-28"
            placeholder="Exprimez-vous..."
            value={texte}
            onChange={(e) => setTexte(e.target.value)}
          ></textarea>

          {mediaPreview && (
            <div className="rounded-lg overflow-hidden border border-base-300/50">
              {mediaType === 'image' ? (
                <img src={mediaPreview} alt="Aperçu" className="w-full h-auto object-cover" />
              ) : (
                <video src={mediaPreview} controls className="w-full h-auto" />
              )}
            </div>
          )}

          <div className="modal-action justify-between items-center mt-6">
             <div className="flex gap-4">
                <button type="button" onClick={() => fileInputRef.current?.click()} className="btn btn-ghost btn-sm gap-2">
                    <ImageIcon size={18} /> Photo
                </button>
             </div>
            <button type="submit" className="btn btn-primary" disabled={isSubmitting || (!texte.trim() && !media)}>
              {isSubmitting ? <span className="loading loading-spinner"></span> : "Publier"}
            </button>
          </div>

          <input
            type="file"
            ref={fileInputRef}
            className="hidden"
            accept="image/*,video/*"
            onChange={handleMediaChange}
          />
        </form>
      </div>
       <div className="modal-backdrop">
        <button onClick={onClose}>close</button>
      </div>
    </div>
  );
}
