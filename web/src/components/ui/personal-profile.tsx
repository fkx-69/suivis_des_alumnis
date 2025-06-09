"use client";

import React, { useState, useEffect, useRef } from "react";
import { Edit2 as Pencil } from "lucide-react";
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
  const profileContentRef = useRef<HTMLDivElement>(null);

  const handleChange = (label: string, newValue: string) => {
    setFields((prev) =>
      prev.map((f) => (f.label === label ? { ...f, value: newValue } : f))
    );
    setShowButton(true);
  };

  const handleKeyDown = (
    e: React.KeyboardEvent<HTMLInputElement>,
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
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
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
            <div className="w-24 rounded-full">
              <img src="/profile/avatar.jpg" alt="Profile" />
            </div>
          </div>
          <h1 className="mt-3 text-xl font-semibold">
            {user?.prenom} {user?.nom}
          </h1>
          <p className="text-sm text-gray-500">{user?.role}</p>
        </div>

        {/* champs */}
        <div className="mt-6 space-y-2">
          {fields.map((field) => (
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
                  value={field.value}
                  autoFocus
                  onChange={(e) => handleChange(field.label, e.target.value)}
                  onBlur={() => setEditing(null)}
                  onKeyDown={(e) => handleKeyDown(e, field.label)}
                />
              ) : (
                <span className="flex items-center gap-1">
                  {field.value}
                  <Pencil
                    className="h-4 w-4 cursor-pointer text-gray-400 hover:text-gray-600"
                    onClick={() => setEditing(field.label)}
                  />
                </span>
              )}
            </div>
          ))}
        </div>

        {/* bouton */}
        {showButton && (
          <div className="mt-6 flex justify-center">
            <button
              className="btn btn-primary btn-sm"
              onClick={async () => {
                setShowButton(false);
                if (!user) return;

                const data: Record<string, string> = {};
                fields.forEach((f) => {
                  if (f.label === "Username" && f.value !== user.username)
                    data.username = f.value;
                  if (f.label === "Prenoms" && f.value !== user.prenom)
                    data.prenom = f.value;
                  if (f.label === "Nom" && f.value !== user.nom)
                    data.nom = f.value;
                });

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
