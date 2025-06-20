"use client";
import { useParams } from "next/navigation";
import { useEffect, useState } from "react";
import { fetchGroups, fetchGroupMessages, sendGroupMessage } from "@/lib/api/group";
import { Group, GroupMessage } from "@/types/group";
import { Input } from "@/components/ui/Input";

export default function GroupeDetailPage() {
  const { id } = useParams<{ id: string }>();
  const [group, setGroup] = useState<Group | null>(null);
  const [messages, setMessages] = useState<GroupMessage[]>([]);
  const [content, setContent] = useState("");

  useEffect(() => {
    if (!id) return;
    fetchGroups().then((gs) => {
      setGroup(gs.find((g) => g.id === Number(id)) || null);
    });
    fetchGroupMessages(Number(id)).then(setMessages);
  }, [id]);

  const handleSend = async () => {
    if (!content.trim()) return;
    const msg = await sendGroupMessage(Number(id), content);
    setMessages((prev) => [...prev, msg]);
    setContent("");
  };

  if (!group) {
    return (
      <div className="flex justify-center p-4">
        <span className="loading loading-spinner" />
      </div>
    );
  }

  return (
    <main className="flex flex-col h-screen p-4">
      <h1 className="text-xl font-semibold mb-4">{group.nom_groupe}</h1>
      <div className="flex-1 overflow-y-auto space-y-2">
        {messages.map((m) => (
          <div key={m.id} className="chat chat-start">
            <div className="chat-bubble">
              <strong>{m.auteur}:</strong> {m.contenu}
            </div>
          </div>
        ))}
      </div>
      <div className="mt-2 flex gap-2">
        <Input
          className="flex-1"
          placeholder="Votre message"
          value={content}
          onChange={(e) => setContent(e.target.value)}
        />
        <button className="btn btn-primary" onClick={handleSend} disabled={!content.trim()}>
          Envoyer
        </button>
      </div>
    </main>
  );
}
