"use client";
import { useEffect, useState, useRef } from "react";
import Image from "next/image";
import { useParams } from "next/navigation";
import {
  fetchGroups,
  fetchGroupMessages,
  sendGroupMessage,
} from "@/lib/api/group";
import { Group, GroupMessage } from "@/types/group";
import { useAuth } from "@/lib/api/authContext";
import { Send } from "lucide-react";

export default function GroupeDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const [group, setGroup] = useState<Group | null>(null);
  const [messages, setMessages] = useState<GroupMessage[]>([]);
  const [content, setContent] = useState("");
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    if (!id) return;

    fetchGroups().then((groups) => {
      setGroup(groups.find((g) => g.id === Number(id)) || null);
    });
    fetchGroupMessages(Number(id)).then(setMessages);
  }, [id]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;

    try {
      const newMessage = await sendGroupMessage(Number(id), content);
      setMessages((prev) => [...prev, newMessage]);
      setContent("");
    } catch (error) {
      console.error("Failed to send message:", error);
    }
  };

  if (!group || !user) {
    return (
      <div className="flex h-screen items-center justify-center">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full bg-base-200">
      <header className="bg-base-100 p-4 text-base-content border-b border-base-300 shadow-sm flex items-center gap-3">
        <div className="w-10 h-10 rounded-full overflow-hidden bg-neutral-focus text-neutral-content flex items-center justify-center">
          {group.image ? (
            <Image src={group.image} alt={group.nom_groupe} width={40} height={40} className="object-cover w-10 h-10" unoptimized />
          ) : (
            <span>{group.nom_groupe.substring(0, 2)}</span>
          )}
        </div>
        <h1 className="text-xl font-semibold">{group.nom_groupe}</h1>
      </header>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((m) => {
          const isCurrentUser = user.username === m.auteur;

          if (isCurrentUser) {
            return (
              <div key={m.id} className="flex items-end justify-end gap-3">
                <div className="chat-bubble chat-bubble-primary shadow">{m.contenu}</div>
                <div className="avatar">
                  <div className="w-9 rounded-full">
                  <Image
                    src={
                      user.photo_profil
                        ? `http://127.0.0.1:8000/${user.photo_profil}`
                        : `https://ui-avatars.com/api/?name=${user.prenom}+${user.nom}&background=random`
                    }
                    alt="My Avatar"
                    width={36}
                    height={36}
                    unoptimized
                  />
                </div>
              </div>
            </div>
          );
        }

          return (
            <div key={m.id} className="flex items-end gap-3">
              <div className="avatar">
                <div className="w-9 rounded-full">
                  <Image
                    src={`https://ui-avatars.com/api/?name=${m.auteur}&background=random`}
                    alt={m.auteur}
                    width={36}
                    height={36}
                    unoptimized
                  />
                </div>
              </div>
              <div className="chat-bubble bg-base-100 text-base-content shadow">{m.contenu}</div>
            </div>
          );
        })}
        <div ref={messagesEndRef} />
      </div>

      <footer className="bg-base-100 border-t border-base-300 p-4">
        <form onSubmit={handleSend} className="flex items-center gap-2">
          <input
            type="text"
            className="input input-bordered flex-1"
            placeholder="Écrire un message..."
            value={content}
            onChange={(e) => setContent(e.target.value)}
          />
          <button
            type="submit"
            className="btn btn-primary"
            disabled={!content.trim()}
          >
            <Send size={20} />
          </button>
        </form>
      </footer>
    </div>
  );
}
