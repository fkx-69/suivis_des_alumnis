import { motion } from "framer-motion";
import { useState, useEffect } from "react";
import { createReport } from "@/lib/api/report";
import { toast } from "@/components/ui/toast";

interface ReportUserModalProps {
  userId: number;
  onClose(): void;
}

export default function ReportUserModal({ userId, onClose }: ReportUserModalProps) {
  const [reason, setReason] = useState("comportement_inapproprié");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [onClose]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await createReport(userId, reason);
      toast.success("Utilisateur signalé");
      onClose();
    } catch (err) {
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={onClose}
    >
      <motion.form
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.25 }}
        className="relative w-full max-w-sm bg-base-100 rounded-lg p-6 shadow-xl space-y-4"
        onClick={(e) => e.stopPropagation()}
        onSubmit={handleSubmit}
      >
        <h2 className="text-lg font-bold">Signaler l'utilisateur</h2>
        <select
          className="select select-bordered w-full"
          value={reason}
          onChange={(e) => setReason(e.target.value)}
        >
          <option value="comportement_inapproprié">Comportement inapproprié</option>
          <option value="contenu_inapproprié">Contenu inapproprié</option>
          <option value="autre">Autre</option>
        </select>
        <div className="flex justify-end gap-2 pt-2">
          <button type="button" className="btn" onClick={onClose}>
            Annuler
          </button>
          <button type="submit" className="btn btn-error" disabled={submitting}>
            {submitting ? <span className="loading loading-spinner"></span> : "Signaler"}
          </button>
        </div>
      </motion.form>
    </div>
  );
}
