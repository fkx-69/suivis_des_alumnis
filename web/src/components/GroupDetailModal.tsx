import React from "react";
import { motion } from "framer-motion";
import { XIcon, Users, Calendar } from "lucide-react";
import Image from "next/image";
import { Group } from "@/types/group";

interface GroupDetailModalProps {
  group: Group;
  onClose: () => void;
}

export default function GroupDetailModal({
  group,
  onClose,
}: GroupDetailModalProps) {
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
        className="relative w-full max-w-lg bg-base-100 rounded-2xl shadow-xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {group.image && (
          <figure>
            <Image
              src={group.image}
              alt={group.nom_groupe}
              width={768}
              height={256}
              className="w-full h-64 object-cover"
            />
          </figure>
        )}
        <div className="p-8">
          <h2 className="text-2xl font-bold mb-2">{group.nom_groupe}</h2>
          <p className="mb-4 whitespace-pre-line text-base-content/80">
            {group.description}
          </p>
          <div className="flex justify-between items-center text-sm text-base-content/70">
            <div className="flex items-center gap-2">
              <Users size={16} />
              <span>{group.membres.length} membre(s)</span>
            </div>
            <div className="flex items-center gap-2">
              <Calendar size={16} />
              <span>
                Créé le {new Date(group.date_creation).toLocaleDateString()}
              </span>
            </div>
          </div>
        </div>
        <button
          className="btn btn-sm btn-circle btn-ghost absolute top-3 right-3 z-10"
          type="button"
          onClick={onClose}
        >
          <XIcon size={20} />
        </button>
      </motion.div>
    </div>
  );
}
