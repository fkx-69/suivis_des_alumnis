"use client";
import { useEffect, useState } from "react";
import { fetchReports, banUser, deleteUser } from "@/lib/api/report";
import { Report } from "@/types/report";

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>([]);

  useEffect(() => {
    fetchReports().then(setReports);
  }, []);

  const handleBan = async (id: number) => {
    await banUser(id);
    alert("Utilisateur banni");
  };

  const handleDelete = async (id: number) => {
    await deleteUser(id);
    setReports((prev) => prev.filter((r) => r.reported_user.id !== id));
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-2">
      <h1 className="text-2xl font-semibold">Signalements</h1>
      <ul className="space-y-2">
        {reports.map((r) => (
          <li key={r.id} className="p-2 bg-base-200 rounded-md space-y-1">
            <p>
              {r.reported_user.username} signalé pour {r.reason}
            </p>
            <div className="space-x-2">
              <button className="btn btn-xs" onClick={() => handleBan(r.reported_user.id)}>
                Bannir
              </button>
              <button className="btn btn-xs" onClick={() => handleDelete(r.reported_user.id)}>
                Supprimer
              </button>
            </div>
          </li>
        ))}
      </ul>
    </main>
  );
}
