"use client";
import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { fetchGroups } from "@/lib/api/group";
import { Group } from "@/types/group";

export default function GroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const [groups, setGroups] = useState<Group[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchGroups()
      .then(setGroups)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="flex h-screen overflow-hidden">
      <div className="w-1/4 bg-base-100 border-r border-base-300 flex flex-col">
        <header className="p-4 border-b border-base-300 bg-primary text-primary-content">
          <h1 className="text-2xl font-semibold">Groupes</h1>
        </header>
        <div className="overflow-y-auto h-full p-3">
          {loading ? (
            <div className="flex justify-center items-center h-full">
              <p>Chargement des groupes...</p>
            </div>
          ) : (
            groups.map((g) => {
              const isActive = pathname === `/groupes/${g.id}`;
              return (
                <Link key={g.id} href={`/groupes/${g.id}`}>
                  <div
                    className={`flex items-center mb-4 cursor-pointer p-2 rounded-md ${isActive ? "bg-base-300" : "hover:bg-base-200"}`}
                  >
                    <div className="w-12 h-12 rounded-full overflow-hidden mr-3 bg-gray-300 flex items-center justify-center">
                      {g.image ? (
                        <Image src={g.image} alt={g.nom_groupe} width={48} height={48} className="w-12 h-12 object-cover" unoptimized />
                      ) : (
                        <span className="text-sm font-bold text-neutral-content bg-neutral-focus w-full h-full flex items-center justify-center">
                          {g.nom_groupe.substring(0, 2)}
                        </span>
                      )}
                    </div>
                    <div className="flex-1 overflow-hidden">
                      <p className="font-semibold truncate">{g.nom_groupe}</p>
                      <p className="text-base-content/70 truncate">
                        {g.description || ""}
                      </p>
                    </div>
                  </div>
                </Link>
              );
            })
          )}
        </div>
      </div>
      <main className="flex-1 h-full overflow-y-auto">{children}</main>
    </div>
  );
}
