"use client";

import React, { useState } from "react";
import { Edit2 as Pencil } from "lucide-react";
import Image from "next/image";
import { useAuth } from "@/lib/api/authContext";
import EditProfileModal from "./EditProfileModal";

export default function ProfileDetails() {
  const { user } = useAuth();
  const [isModalOpen, setModalOpen] = useState(false);

  if (!user) {
    return (
      <div className="flex justify-center items-center h-full">
        <span className="loading loading-spinner"></span>
      </div>
    );
  }

  const photoUrl = user.photo_profil
    ? `http://127.0.0.1:8000/${user.photo_profil}`
    : `https://ui-avatars.com/api/?name=${user.prenom}+${user.nom}&background=random`;

  return (
    <>
      <div className="relative bg-base-100 rounded-2xl shadow-lg overflow-hidden">
        {/* -- Background Image -- */}
        <div className="h-40 bg-cover bg-center"></div>

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
              <Image
                src={photoUrl}
                alt={`${user.prenom} ${user.nom}`}
                width={112}
                height={112}
                sizes="480px"
              />
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
            {user.biographie || "Aucune biographie pour le moment."}
          </p>
        </div>
      </div>

      {isModalOpen && <EditProfileModal onClose={() => setModalOpen(false)} />}
    </>
  );
}
