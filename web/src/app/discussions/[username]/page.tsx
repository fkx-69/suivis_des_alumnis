"use client";
import { useEffect, useState, useRef } from "react";
import { useParams } from "next/navigation";
import {
  fetchMessages,
  fetchConversations,
  sendMessage as sendMessageApi,
} from "@/lib/api/messaging";
import { Conversation, Message } from "@/types/messaging";
import { Input } from "@/components/ui/Input";

export default function ConversationPage() {
  const { username } = useParams<{ username: string }>();
  const [conversation, setConversation] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [content, setContent] = useState("");
  const wsRef = useRef<WebSocket | null>(null);
  const [socketOpen, setSocketOpen] = useState(false);

  useEffect(() => {
    if (!username) return;

    fetchMessages(username).then((msgs) => {
      setMessages(msgs);
    });

    fetchConversations().then((convs) => {
      const conv = convs.find((c) => c.username === username) || null;
      setConversation(conv);
      if (conv) {
        openSocket(conv.id);
      }
    });

    return () => {
      wsRef.current?.close();
      setSocketOpen(false);
    };
  }, [username]);

  function openSocket(userId: number) {
    const protocol = window.location.protocol === "https:" ? "wss" : "ws";
    const ws = new WebSocket(
      `${protocol}://${window.location.host}/ws/notifications/`
    );
    wsRef.current = ws;
    ws.onopen = () => setSocketOpen(true);
    ws.onmessage = (event) => {
      const msg: Message = JSON.parse(event.data);
      setMessages((prev) => [...prev, msg]);
    };
  }

  async function sendMessage() {
    if (!content.trim()) return;
    const msg = await sendMessageApi(username, content);
    setMessages((prev) => [...prev, msg]);
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
    <main className="flex flex-col h-screen mx-auto max-w-7xl px-4 py-4">
      <h2 className="text-xl font-semibold mb-4">
        Conversation avec {conversation.prenom} {conversation.nom}
      </h2>
      <div className="flex-1 overflow-y-auto space-y-2">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`chat ${m.expediteur_username === conversation.username ? "chat-start" : "chat-end"}`}
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
        <button
          className="btn btn-primary"
          onClick={sendMessage}
          disabled={!content.trim()}
        >
          Envoyer
        </button>
      </div>
    </main>
  );
}
