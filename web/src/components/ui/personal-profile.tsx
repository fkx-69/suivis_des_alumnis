"use client";

import React, { useState, useEffect, useRef } from "react";
import { Edit2 as Pencil } from "lucide-react";
import { motion } from "framer-motion";
import { useAuth } from "@/lib/api/authContext";

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
    { label: "Role", value: user.role },
  ];
}

interface PersonalProfileProps {
  onClose: () => void;
}
export default function PersonalProfile({ onClose }: PersonalProfileProps) {
  const { user } = useAuth();
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
    if (e.key === "Enter") {
      setEditing(null);
    }
  };

  useEffect(() => {
    const handleEscKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        onClose();
      }
    };
    document.addEventListener("keydown", handleEscKey);
    return () => {
      document.removeEventListener("keydown", handleEscKey);
    };
  }, [onClose]);

  useEffect(() => {
    setFields(buildFields(user));
  }, [user]);

  return (
    <div
      className="cards fixed flex flex-auto top-0 left-0 w-full h-full z-50 items-center justify-center bg-opacity-30"
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          onClose();
        }
      }}
    >
      <motion.div
        ref={profileContentRef}
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
        className="w-full max-w-3xl bg-white border border-gray-200 rounded-b-md shadow p-8"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex flex-col items-center">
          <div className="avatar">
            <div className="w-24 rounded-full">
              <img src="/profile/avatar.jpg" alt="Profile" className="" />
            </div>
          </div>
          <h1 className="mt-4 text-2xl font-semibold text-gray-800">
            Fabien Konaré
          </h1>
          <p className="text-gray-500 flex items-center">Alumni </p>
        </div>

        <div className="card-body">
          <div className="mt-8 space-y-6">
            {fields.map((field) => (
              <div
                key={field.label}
                className="flex justify-between items-center"
              >
                <span className="font-medium text-gray-700">{field.label}</span>
                <div className="flex items-center text-gray-500">
                  {editing === field.label ? (
                    <input
                      type="text"
                      className="input input-primary bg-white border-b border-gray-300 focus:outline-none text-gray-800"
                      value={field.value}
                      autoFocus
                      onChange={(e) =>
                        handleChange(field.label, e.target.value)
                      }
                      onBlur={() => setEditing(null)}
                      onKeyDown={(e) => handleKeyDown(e, field.label)}
                    />
                  ) : (
                    <>
                      <span>{field.value}</span>
                      <Pencil
                        className="ml-2 h-4 w-4 text-gray-400 hover:text-gray-600 cursor-pointer"
                        onClick={() => setEditing(field.label)}
                      />
                    </>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="flex justify-center mt-6">
          {showButton && (
            <button
              className="btn btn-primary"
              onClick={() => {
                setShowButton(false);
                console.log("Saving changes:", fields);
                onClose();
              }}
            >
              Enregistrer
            </button>
          )}
        </div>
      </motion.div>
    </div>
  );
}
