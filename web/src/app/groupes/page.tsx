"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { fetchGroups, joinGroup, leaveGroup } from "@/lib/api/group";
import AddGroupModal from "@/components/AddGroupModal";
import { Group } from "@/types/group";

export default function GroupesPage() {
  const [groups, setGroups] = useState<Group[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);

  useEffect(() => {
    fetchGroups()
      .then(setGroups)
      .finally(() => setLoading(false));
  }, []);

  const handleJoin = async (id: number) => {
    await joinGroup(id);
    setGroups((prev) =>
      prev.map((g) => (g.id === id ? { ...g, est_membre: true } : g))
    );
  };

  const handleLeave = async (id: number) => {
    await leaveGroup(id);
    setGroups((prev) =>
      prev.map((g) => (g.id === id ? { ...g, est_membre: false } : g))
    );
  };

  const handleCreated = (g: Group) => {
    setGroups((prev) => [g, ...prev]);
  };

  if (loading) {
    return (
      <div className="flex justify-center p-4">
        <span className="loading loading-spinner" />
      </div>
    );
  }

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-4">
      <h1 className="text-2xl font-semibold">Groupes</h1>
      <button className="btn btn-primary" onClick={() => setShowForm(true)}>
        Créer un groupe
      </button>
      <ul className="space-y-2">
        {groups.map((g) => (
          <li key={g.id} className="p-3 bg-base-200 rounded-md">
            <Link href={`/groupes/${g.id}`} className="font-semibold">
              {g.nom_groupe}
            </Link>
            <p className="text-sm opacity-80">{g.description}</p>
            {g.est_membre ? (
              <button className="btn btn-sm mt-2" onClick={() => handleLeave(g.id)}>
                Quitter
              </button>
            ) : (
              <button className="btn btn-sm mt-2" onClick={() => handleJoin(g.id)}>
                Rejoindre
              </button>
            )}
          </li>
        ))}
      </ul>
      {showForm && <AddGroupModal onClose={() => setShowForm(false)} onCreated={handleCreated} />}
    </main>
  );
}
