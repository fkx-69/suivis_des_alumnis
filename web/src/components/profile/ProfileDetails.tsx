"use client";

import React, { useState } from "react";
import { Edit2 as Pencil } from "lucide-react";
import { useAuth } from "@/lib/api/authContext";
import EditProfileModal from "./EditProfileModal";

export default function ProfileDetails() {
  const { user } = useAuth();
  const [isModalOpen, setModalOpen] = useState(false);
  const [saved, setSaved] = useState(false);

  if (!user) {
    return (
      <div className="p-6 bg-base-100 rounded-2xl shadow-lg animate-pulse space-y-4">
        <div className="h-40 bg-base-200 rounded w-full" />
        <div className="flex items-center space-x-4 mt-4">
          <div className="w-20 h-20 rounded-full bg-base-200" />
          <div className="flex-1 space-y-2">
            <div className="h-4 bg-base-200 rounded w-1/3" />
            <div className="h-3 bg-base-200 rounded w-1/4" />
          </div>
        </div>
        <div className="space-y-2">
          <div className="h-3 bg-base-200 rounded" />
          <div className="h-3 bg-base-200 rounded w-5/6" />
        </div>
      </div>
    );
  }

  const photoUrl = user.photo_profil
    ? `http://127.0.0.1:8000/${user.photo_profil}`
    : `https://ui-avatars.com/api/?name=${user.prenom}+${user.nom}&background=random`;
  const coverUrl = user.photo_couverture
    ? `http://127.0.0.1:8000/${user.photo_couverture}`
    : 'https://source.unsplash.com/1600x900/?abstract,gradient';

  return (
    <>
      <div className="relative bg-base-100 rounded-2xl shadow-lg overflow-hidden">
        {/* -- Background Image -- */}
        <div
          className="h-40 bg-cover bg-center"
          style={{ backgroundImage: `url(${coverUrl})` }}
        ></div>
        {saved && (
          <div className="badge badge-success absolute top-2 left-2 animate-bounce">
            Sauvegardé !
          </div>
        )}

        {/* -- Edit Button -- */}
        <button 
          onClick={() => setModalOpen(true)}
          className="btn btn-sm btn-square absolute top-4 right-4"
        >
          <Pencil size={16} />
        </button>

        {/* -- Profile Picture -- */}
        <div className="absolute top-24 left-6">
          <div className="avatar">
            <div className="w-28 h-28 rounded-full ring-4 ring-base-100">
              <img src={photoUrl} alt={`${user.prenom} ${user.nom}`} />
            </div>
          </div>
        </div>

        {/* -- User Info -- */}
        <div className="p-6 pt-16">
          <h2 className="text-2xl font-bold">
            {user.prenom} {user.nom}
          </h2>
          <p className="text-neutral-500 font-semibold">@{user.username}</p>
          <p className="text-sm text-neutral-600 mt-1">{user.email}</p>
          
          <div className="divider my-4"></div>

          {/* -- Biography -- */}
          <h3 className="font-bold text-lg mb-2">Biographie</h3>
          <p className="text-neutral-600 text-sm">
            {user.biographie || 'Aucune biographie pour le moment.'}
          </p>
        </div>
      </div>

      {isModalOpen && (
        <EditProfileModal
          onClose={() => setModalOpen(false)}
          onSaved={() => {
            setSaved(true);
            setTimeout(() => setSaved(false), 3000);
          }}
        />
      )}
    </>
  );
}
