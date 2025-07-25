import { useState, useRef } from "react";
import { Image as ImageIcon, X as XIcon } from "lucide-react";
import Image from "next/image";

interface AddPublicationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onPublish: (formData: FormData) => Promise<void>;
}

export default function AddPublicationModal({
  isOpen,
  onClose,
  onPublish,
}: AddPublicationModalProps) {
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
      formData.append(
        media.type.startsWith("image/") ? "photo" : "video",
        media
      );
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
    <div
      className="modal modal-open modal-bottom sm:modal-middle"
      onClick={onClose}
    >
      <div className="modal-box relative" onClick={(e) => e.stopPropagation()}>
        <h3 className="font-bold text-lg mb-4">Créer une publication</h3>

        <form onSubmit={handleSubmit} className="space-y-4">
          <textarea
            className="textarea textarea-bordered w-full h-28"
            placeholder="Exprimez-vous..."
            value={texte}
            onChange={(e) => setTexte(e.target.value)}
          ></textarea>
          {mediaPreview && (
            <div className="relative rounded-lg overflow-hidden border border-base-300/50">
              <button
                type="button"
                className="btn btn-sm btn-circle absolute top-2 right-2 z-10"
                onClick={() => {
                  setMedia(null);
                  setMediaPreview(null);
                  if (fileInputRef.current) fileInputRef.current.value = "";
                }}
              >
                <XIcon size={18} />
              </button>
              {mediaType === "image" ? (
                <Image
                  src={mediaPreview}
                  alt="Aperçu"
                  width={640}
                  height={320}
                  className="w-full h-48 object-cover"
                />
              ) : (
                <video src={mediaPreview} controls className="w-full h-auto" />
              )}
            </div>
          )}
          <div className="modal-action justify-between items-center mt-6">
            <div className="flex gap-4">
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="btn btn-ghost btn-sm gap-2"
              >
                <ImageIcon size={18} /> Photo
              </button>
            </div>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={isSubmitting || (!texte.trim() && !media)}
            >
              {isSubmitting ? (
                <span className="loading loading-spinner"></span>
              ) : (
                "Publier"
              )}
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
    </div>
  );
}
