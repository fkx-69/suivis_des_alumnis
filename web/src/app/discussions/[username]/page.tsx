"use client";
import { useEffect, useState, useRef } from "react";
import { useParams } from "next/navigation";
import {
  fetchMessages,
  fetchConversations,
  sendMessage as sendMessageApi,
} from "@/lib/api/messaging";
import { fetchUserProfile } from "@/lib/api/users";
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

    const setupConversation = async () => {
      try {
        const allConversations = await fetchConversations();
        const existingConv = allConversations.find((c) => c.username === username);

        if (existingConv) {
          // La conversation existe, on charge les messages et on ouvre le socket
          setConversation(existingConv);
          const msgs = await fetchMessages(username);
          setMessages(msgs);
          openSocket(existingConv.id);
        } else {
          // C'est une nouvelle conversation, on crée un placeholder
          const userProfile = await fetchUserProfile(username);
          const placeholderConv = {
            ...userProfile,
            id: -1, // Pas encore de vrai ID
          };
          setConversation(placeholderConv as Conversation);
          setMessages([]); // Pas encore de messages
        }
      } catch (error) {
        console.error("Erreur lors de l'initialisation de la conversation:", error);
      }
    };

    setupConversation();

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
    if (!content.trim() || !conversation) return;

    try {
      const msg = await sendMessageApi(username, content);
      setMessages((prev) => [...prev, msg]);
      setContent("");

      // Si c'était une nouvelle conversation, on récupère ses infos et on ouvre le socket
      if (conversation.id === -1) {
        const allConversations = await fetchConversations();
        const newConv = allConversations.find((c) => c.username === username);
        if (newConv) {
          setConversation(newConv);
          openSocket(newConv.id);
        }
      }
    } catch (error) {
      console.error("Erreur lors de l'envoi du message:", error);
    }
  }

  if (!conversation) {
    return (
      <div className="flex justify-center items-center h-full">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full">
      <header className="p-4 border-b border-base-300">
        <h2 className="text-xl font-semibold">
          {conversation.prenom} {conversation.nom}
        </h2>
      </header>
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-base-200/50">
        {messages.map((m) => (
          <div
            key={m.id}
            className={`chat ${
              m.expediteur_username === conversation.username
                ? "chat-start"
                : "chat-end"
            }`}
          >
            <div className="chat-bubble max-w-lg">{m.contenu}</div>
          </div>
        ))}
      </div>
      <footer className="p-4 border-t border-base-300">
        <div className="flex gap-2">
          <Input
            className="flex-1"
            placeholder="Votre message..."
            value={content}
            onChange={(e) => setContent(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && sendMessage()}
          />
          <button
            className="btn btn-primary"
            onClick={sendMessage}
          >
            Envoyer
          </button>
        </div>
      </footer>
    </div>
  );
}
