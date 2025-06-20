"use client";

import { motion } from "framer-motion";

interface ConfirmModalProps {
  title?: string;
  message?: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm(): void;
  onCancel(): void;
}

export default function ConfirmModal({
  title,
  message,
  confirmText = "Confirmer",
  cancelText = "Annuler",
  onConfirm,
  onCancel,
}: ConfirmModalProps) {
  return (
    <div
      className="absolute inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={(e) => e.target === e.currentTarget && onCancel()}
    >
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-sm bg-base-100 rounded-lg p-6 shadow-xl space-y-4"
        onClick={(e) => e.stopPropagation()}
      >
        {title && <h2 className="text-lg font-bold">{title}</h2>}
        {message && <p className="text-sm opacity-80 whitespace-pre-line">{message}</p>}
        <div className="flex justify-end gap-2 pt-2">
          <button className="btn" type="button" onClick={onCancel}>
            {cancelText}
          </button>
          <button className="btn btn-error" type="button" onClick={onConfirm}>
            {confirmText}
          </button>
        </div>
      </motion.div>
    </div>
  );
}
