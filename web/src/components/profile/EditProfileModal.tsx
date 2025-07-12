"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import { CameraIcon } from "lucide-react";
import { motion } from "framer-motion";
import { useAuth } from "@/lib/api/authContext";
import { updateProfile, changeEmail } from "@/lib/api/auth";
import type { User } from "@/types/auth";
import { toast } from "@/components/ui/toast";

interface ProfileField {
  label: string;
  value: string;
}

function buildFields(user: User | null): ProfileField[] {
  if (!user) return [];
  return [
    { label: "Username", value: user.username },
    { label: "Email", value: user.email },
    { label: "Prenoms", value: user.prenom },
    { label: "Nom", value: user.nom },
    { label: "Biographie", value: user.biographie ?? "" },
  ];
}

interface EditProfileModalProps {
  onClose: () => void;
}

export default function EditProfileModal({ onClose }: EditProfileModalProps) {
  const { user, updateUser } = useAuth();
  const [fields, setFields] = useState<ProfileField[]>(buildFields(user));
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);

  useEffect(() => {
    if (user?.photo_profil) {
      setPreviewUrl("http://127.0.0.1:8000/" + user.photo_profil);
    }
  }, [user]);

  const handleChange = (label: string, newValue: string) => {
    setFields((prev) =>
      prev.map((f) => (f.label === label ? { ...f, value: newValue } : f))
    );
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    setSelectedFile(file);
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewUrl(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSubmit = async () => {
    if (!user) return;

    const data: Record<string, string | File | null | undefined> = {};
    fields.forEach((f) => {
      if (f.label === "Username" && f.value !== user.username)
        data.username = f.value;
      if (f.label === "Prenoms" && f.value !== user.prenom)
        data.prenom = f.value;
      if (f.label === "Nom" && f.value !== user.nom) data.nom = f.value;
      if (f.label === "Biographie" && f.value !== (user.biographie ?? ""))
        data.biographie = f.value;
    });

    if (selectedFile) {
      data.photo_profil = selectedFile;
    }

    try {
      let newUser = user;
      const emailField = fields.find((f) => f.label === "Email");
      if (emailField && emailField.value !== user.email) {
        await changeEmail({ email: emailField.value });
        newUser = { ...newUser, email: emailField.value };
      }
      if (Object.keys(data).length) {
        const updated = await updateProfile(data);
        newUser = { ...newUser, ...updated };
        setSelectedFile(null);
      }
      updateUser(newUser);
      toast.success("Profil mis à jour");
    } catch {
      toast.error("Erreur lors de la mise à jour");
    } finally {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60"
      onClick={onClose}
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.9 }}
        transition={{ duration: 0.2 }}
        onClick={(e) => e.stopPropagation()}
        className="w-full max-w-lg rounded-2xl bg-base-100 p-6 shadow-xl"
      >
        <h2 className="text-2xl font-bold mb-6">Modifier le profil</h2>

        {/* Form */}
        <div className="flex flex-col items-center mb-6">
          <div className="avatar">
            <div className="w-24 rounded-full relative group overflow-hidden">
              <Image
                src={
                  previewUrl ||
                  `https://ui-avatars.com/api/?name=${user?.prenom}+${user?.nom}&background=random`
                }
                alt="Profile Preview"
                width={96}
                height={96}
                className="object-cover w-full h-full"
              />
              <label
                htmlFor="photo-upload-modal"
                className="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 group-hover:opacity-100 cursor-pointer"
              >
                <CameraIcon className="text-white h-6 w-6" />
              </label>
              <input
                id="photo-upload-modal"
                type="file"
                className="hidden"
                accept="image/*"
                onChange={handleFileChange}
              />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          {fields.map((field) => (
            <div key={field.label}>
              <label className="label">
                <span className="label-text">{field.label}</span>
              </label>
              {field.label === "Biographie" ? (
                <textarea
                  className="textarea textarea-bordered w-full"
                  value={field.value}
                  onChange={(e) => handleChange(field.label, e.target.value)}
                  rows={4}
                />
              ) : (
                <input
                  type={field.label === "Email" ? "email" : "text"}
                  className="input input-bordered w-full"
                  value={field.value}
                  onChange={(e) => handleChange(field.label, e.target.value)}
                />
              )}
            </div>
          ))}
        </div>

        {/* Actions */}
        <div className="mt-8 flex justify-end gap-3">
          <button className="btn btn-ghost" onClick={onClose}>
            Annuler
          </button>
          <button className="btn btn-primary" onClick={handleSubmit}>
            Enregistrer
          </button>
        </div>
      </motion.div>
    </div>
  );
}
