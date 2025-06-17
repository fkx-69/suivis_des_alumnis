"use client";
import { useEffect, useState, useRef } from "react";
import { useParams } from "next/navigation";
import { fetchConversation } from "@/lib/api/messaging";
import { ConversationDetail, Message } from "@/types/messaging";
import { Input } from "@/components/ui/Input";

export default function ConversationPage() {
  const { username } = useParams<{ username: string }>();
  const [conversation, setConversation] = useState<ConversationDetail | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [content, setContent] = useState("");
  const wsRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    if (!username) return;
    fetchConversation(username).then((data) => {
      setConversation(data);
      setMessages(data.messages);
      openSocket(data.user.id);
    });
    return () => {
      wsRef.current?.close();
    };
  }, [username]);

  function openSocket(userId: number) {
    const protocol = window.location.protocol === "https:" ? "wss" : "ws";
    const ws = new WebSocket(`${protocol}://${window.location.host}/ws/chat/${userId}/`);
    wsRef.current = ws;
    ws.onmessage = (event) => {
      const msg: Message = JSON.parse(event.data);
      setMessages((prev) => [...prev, msg]);
    };
  }

  function sendMessage() {
    if (!wsRef.current || !content.trim()) return;
    wsRef.current.send(JSON.stringify({ message: content }));
    setContent("");
  }

  if (!conversation) {
    return (
      <div className="flex justify-center p-4">
        <span className="loading loading-spinner" />
      </div>
    );
  }

  return (
    <main className="flex flex-col h-screen p-4">
      <h2 className="text-xl font-semibold mb-4">
        Conversation avec {conversation.user.prenom} {conversation.user.nom}
      </h2>
      <div className="flex-1 overflow-y-auto space-y-2">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`chat ${m.expediteur_username === conversation.user.username ? "chat-start" : "chat-end"}`}
          >
            <div className="chat-bubble">{m.contenu}</div>
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
        <button className="btn btn-primary" onClick={sendMessage}>
          Envoyer
        </button>
      </div>
    </main>
  );
}
