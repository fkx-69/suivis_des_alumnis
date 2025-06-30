"use client";
"use client";
import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { fetchConversations } from "@/lib/api/messaging";
import { Conversation } from "@/types/messaging";
import { useAuth } from "@/lib/api/authContext";

export default function DiscussionsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  const { user } = useAuth();
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchConversations()
      .then(setConversations)
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="flex h-full">
      <main className="flex-grow bg-base-100 h-full overflow-y-auto">
        {children}
      </main>
      <aside className="w-full max-w-sm border-l border-base-300 flex flex-col bg-base-200 h-full">
        <div className="p-4 border-b border-base-300">
          <h1 className="text-xl font-semibold">Discussions</h1>
        </div>
        <div className="overflow-y-auto flex-grow">
          {loading ? (
            <div className="flex justify-center p-4">
              <span className="loading loading-spinner" />
            </div>
          ) : (
            <ul className="space-y-1 p-2">
              {conversations.map((conv) => {
                const isActive = pathname === `/discussions/${conv.username}`;
                return (
                  <li key={conv.id}>
                    <Link
                      href={`/discussions/${conv.username}`}
                      className={`flex items-center gap-3 p-3 rounded-md transition-colors ${
                        isActive
                          ? "bg-primary text-primary-content"
                          : "hover:bg-base-300"
                      }`}
                    >
                      <div className="avatar">
                        <div className="w-10 rounded-full bg-base-300 overflow-hidden">
                          {conv.photo_profil ? (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img src={conv.photo_profil} alt={conv.username} />
                          ) : (
                            <span className="flex items-center justify-center h-full font-semibold">
                              {conv.username.charAt(0).toUpperCase()}
                            </span>
                          )}
                        </div>
                      </div>
                      <div className="flex-grow overflow-hidden">
                        <p className="font-semibold truncate">
                          {conv.prenom} {conv.nom}
                        </p>
                        <p
                          className={`text-sm truncate ${
                            isActive ? "opacity-80" : "opacity-70"
                          }`}
                        >
                          {conv.last_message ? (
                            conv.last_message
                          ) : (
                            <span className="italic">Aucun message</span>
                          )}
                        </p>
                      </div>
                    </Link>
                  </li>
                );
              })}
            </ul>
          )}
        </div>
      </aside>
    </div>
  );
}
