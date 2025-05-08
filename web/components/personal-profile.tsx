"use client";

import React, { useState, useEffect, useRef } from "react";
import { Edit2 as Pencil } from "lucide-react";
import { motion } from "framer-motion";

interface ProfileField {
  label: string;
  value: string;
}

const initialFields: ProfileField[] = [
  { label: "Username", value: "Fab123" },
  { label: "Email", value: "fab@gmail.com" },
  { label: "Prenoms", value: "Fabien" },
  { label: "Nom", value: "Konaré" },
  { label: "Secteur", value: "Informatique" },
  { label: "Emploie", value: " Developpeur web" },
];

interface PersonalProfileProps {
  onClose: () => void;
}
export default function PersonalProfile({ onClose }: PersonalProfileProps) {
  const [fields, setFields] = useState<ProfileField[]>(initialFields);
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

  return (
    <div
      className="fixed flex flex-auto top-0 left-0 w-full h-full z-50 items-center justify-center bg-opacity-30"
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
          <img
            src="/profile/avatar.jpg"
            alt="Profile"
            className="w-32 h-32 rounded-full object-cover border-2 border-indigo-500"
          />
          <h1 className="mt-4 text-2xl font-semibold text-gray-800">
            Fabien Konaré
          </h1>
          <p className="text-gray-500 flex items-center">Alumni </p>
        </div>

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
                    onChange={(e) => handleChange(field.label, e.target.value)}
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
