"use client";

import React from 'react';
import { motion } from 'framer-motion';
import { XIcon } from 'lucide-react';
import Link from 'next/link';

interface UserProfile {
  username: string;
  nom: string;
  prenom: string;
  photo_profil: string;
  biographie: string;
}

interface ExternalProfileModalProps {
  user: UserProfile;
  onClose: () => void;
}

export default function ExternalProfileModal({ user, onClose }: ExternalProfileModalProps) {

  React.useEffect(() => {
    const handleEsc = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        onClose();
      }
    };
    window.addEventListener('keydown', handleEsc);

    return () => {
      window.removeEventListener('keydown', handleEsc);
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
        <button 
          className="btn btn-sm btn-circle btn-ghost absolute top-3 right-3"
          type="button" 
          onClick={onClose}
        >
          <XIcon size={20} />
        </button>
        
        <div className="flex flex-col items-center text-center">
          <img 
            className="mb-4 w-28 h-28 rounded-full shadow-lg object-cover"
            src={user.photo_profil || '/default-avatar.png'} 
            alt={`Profil de ${user.prenom}`}
          />
          <h3 className="mb-1 text-2xl font-bold text-base-content">{user.prenom} {user.nom}</h3>
          <span className="text-sm text-base-content/70">@{user.username}</span>
          
          {user.biographie && (
            <p className="text-base-content/80 mt-4">
              {user.biographie}
            </p>
          )}
          
          <div className="mt-6">
            <Link href={`/discussions/${user.username}`} className="btn btn-primary w-full" onClick={onClose}>
              Contacter
            </Link>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
