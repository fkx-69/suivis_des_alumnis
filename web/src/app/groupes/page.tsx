"use client";
import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { fetchGroups, joinGroup, leaveGroup } from "@/lib/api/group";
import AddGroupModal from "@/components/AddGroupModal";
import GroupDetailModal from "@/components/GroupDetailModal";
import { Group } from "@/types/group";
import { Plus } from "lucide-react";

export default function GroupesPage() {
  const [groups, setGroups] = useState<Group[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [selectedGroup, setSelectedGroup] = useState<Group | null>(null);
  const router = useRouter();

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
    <main className="p-4 sm:p-6 lg:p-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold tracking-tight">Groupes</h1>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        {groups.map((g) => (
          <div
            key={g.id}
            className="card bg-base-100 shadow-xl border border-primary transition-shadow hover:shadow-2xl cursor-pointer"
            onClick={() => router.push(`/groupes/${g.id}`)}
          >
            {g.image && (
              <figure>
                <Image
                  src={g.image}
                  alt={g.nom_groupe}
                  width={500}
                  height={192}
                  className="w-full h-48 object-cover"
                />
              </figure>
            )}
            <div className="card-body">
              <h2 className="card-title" onClick={(e) => e.stopPropagation()}>
                <Link href={`/groupes/${g.id}`} className="link link-hover">
                  {g.nom_groupe}
                </Link>
              </h2>
              <p
                className="text-base-content/80 line-clamp-3 h-16 hover:text-base-content"
                onClick={(e) => {
                  e.stopPropagation();
                  setSelectedGroup(g);
                }}
              >
                {g.description}
              </p>
              <div
                className="card-actions justify-end mt-4"
                onClick={(e) => e.stopPropagation()}
              >
                {g.est_membre ? (
                  <button
                    className="btn btn-error"
                    onClick={() => handleLeave(g.id)}
                  >
                    Quitter
                  </button>
                ) : (
                  <button
                    className="btn btn-primary"
                    onClick={() => handleJoin(g.id)}
                  >
                    Rejoindre
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
      {showForm && (
        <AddGroupModal
          onClose={() => setShowForm(false)}
          onCreated={handleCreated}
        />
      )}
      {selectedGroup && (
        <GroupDetailModal
          group={selectedGroup}
          onClose={() => setSelectedGroup(null)}
        />
      )}
      <button
        className="btn btn-primary btn-circle fixed bottom-8 right-8 shadow-lg"
        onClick={() => setShowForm(true)}
      >
        <Plus size={24} />
      </button>
    </main>
  );
}
