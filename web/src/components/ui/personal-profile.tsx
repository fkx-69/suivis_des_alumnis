"use client";

import React, { useState, useEffect, useRef } from "react";
import { Edit2 as Pencil, CameraIcon } from "lucide-react";
import { motion } from "framer-motion";
import { useAuth } from "@/lib/api/authContext";
import { updateProfile, changeEmail } from "@/lib/api/auth";
import { toast } from "@/components/ui/toast";

interface ProfileField {
  label: string;
  value: string;
}

function buildFields(user: any): ProfileField[] {
  if (!user) return [];
  return [
    { label: "Username", value: user.username },
    { label: "Email", value: user.email },
    { label: "Prenoms", value: user.prenom },
    { label: "Nom", value: user.nom },
    { label: "Biographie", value: user.biographie ?? "" },
  ];
}

interface PersonalProfileProps {
  onClose: () => void;
}

export default function PersonalProfile({ onClose }: PersonalProfileProps) {
  const { user, login } = useAuth();
  const [fields, setFields] = useState<ProfileField[]>(buildFields(user));
  const [editing, setEditing] = useState<string | null>(null);
  const [showButton, setShowButton] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const profileContentRef = useRef<HTMLDivElement>(null);

  const handleChange = (label: string, newValue: string) => {
    setFields((prev) =>
      prev.map((f) => (f.label === label ? { ...f, value: newValue } : f))
    );
    setShowButton(true);
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] || null;
    setSelectedFile(file);
    if (file) setShowButton(true);
  };

  const handleKeyDown = (
    e: React.KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>,
    label: string
  ) => {
    if (e.key === "Enter") setEditing(null);
  };

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  useEffect(() => setFields(buildFields(user)), [user]);

  return (
    <div
      className="absolute inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={(e) => e.target === e.currentTarget && onClose()}
    >
      <motion.div
        ref={profileContentRef}
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        onClick={(e) => e.stopPropagation()}
        className="w-full max-w-md rounded-lg border border-base-200 bg-base-100 p-6 shadow-xl"
      >
        {/* header */}
        <div className="flex flex-col items-center text-center">
          <div className="avatar">
            <div className="w-24 rounded-full relative group overflow-hidden">
              {user?.photo_profil ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={user.photo_profil}
                  alt="Profile"
                  className="object-cover w-full h-full"
                />
              ) : (
                <svg
                  className="w-full h-full text-base-content bg-base-200"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 100 100"
                >
                  <rect width="100" height="100" fill="currentColor" />
                  <text
                    x="50"
                    y="55"
                    textAnchor="middle"
                    fontSize="50"
                    fill="white"
                  >
                    {user?.username?.charAt(0).toUpperCase()}
                  </text>
                </svg>
              )}
              <label
                htmlFor="photo-upload"
                className="absolute inset-0 flex items-center justify-center bg-black/40 opacity-0 group-hover:opacity-100 cursor-pointer"
              >
                <CameraIcon className="text-white h-5 w-5" />
              </label>
              <input
                id="photo-upload"
                type="file"
                className="hidden"
                accept="image/*"
                onChange={handleFileChange}
              />
            </div>
          </div>
          <h1 className="mt-3 text-xl font-semibold">
            {user?.prenom} {user?.nom}
          </h1>
          <p className="text-sm text-gray-500">{user?.role}</p>
        </div>

        {/* champs */}
        {/* --- Champs --- */}
        <div className="mt-6 space-y-3">
          {fields.map((field) => {
            const isBio = field.label === "Biographie";

            if (isBio) {
              /* --- Cas spécial Biographie --- */
              return (
                <div key={field.label} className="flex flex-col gap-2">
                  <span className="w-full text-center font-medium">
                    {field.label}
                  </span>

                  {editing === field.label ? (
                    <textarea
                      className="textarea textarea-primary w-full"
                      rows={3}
                      autoFocus
                      value={field.value}
                      onChange={(e) =>
                        handleChange(field.label, e.target.value)
                      }
                      onBlur={() => setEditing(null)}
                    />
                  ) : (
                    <div className="relative w-full">
                      <span className="block pr-6">{field.value || "-"}</span>
                      <Pencil
                        className="absolute top-1 right-0 h-4 w-4 cursor-pointer text-gray-400 hover:text-gray-600"
                        onClick={() => setEditing(field.label)}
                      />
                    </div>
                  )}
                </div>
              );
            }

            /* --- Tous les autres champs (une seule ligne) --- */
            return (
              <div
                key={field.label}
                className="flex items-center justify-between gap-2"
              >
                <span className="whitespace-nowrap font-medium">
                  {field.label}
                </span>

                {editing === field.label ? (
                  <input
                    type="text"
                    className="input input-sm input-primary w-full max-w-[60%]"
                    autoFocus
                    value={field.value}
                    onChange={(e) =>
                      handleChange(field.label, e.target.value)
                    }
                    onBlur={() => setEditing(null)}
                    onKeyDown={(e) => handleKeyDown(e, field.label)}
                  />
                ) : (
                  <span className="flex items-center gap-1">
                    {field.value || "-"}
                    <Pencil
                      className="h-4 w-4 cursor-pointer text-gray-400 hover:text-gray-600"
                      onClick={() => setEditing(field.label)}
                    />
                  </span>
                )}
              </div>
            );
          })}
        </div>

        {/* bouton */}
        {showButton && (
          <div className="mt-6 flex justify-center">
            <button
              className="btn btn-primary btn-sm"
              onClick={async () => {
                setShowButton(false);
                if (!user) return;

                const data: Record<string, any> = {};
                fields.forEach((f) => {
                  if (f.label === "Username" && f.value !== user.username)
                    data.username = f.value;
                  if (f.label === "Prenoms" && f.value !== user.prenom)
                    data.prenom = f.value;
                  if (f.label === "Nom" && f.value !== user.nom)
                    data.nom = f.value;
                  if (
                    f.label === "Biographie" &&
                    f.value !== (user.biographie ?? "")
                  )
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
                  login(newUser);
                  toast.success("Profil mis à jour");
                } catch {
                  toast.error("Erreur lors de la mise à jour");
                } finally {
                  onClose();
                }
              }}
            >
              Enregistrer
            </button>
          </div>
        )}
      </motion.div>
    </div>
  );
}
