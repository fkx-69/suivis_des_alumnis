"use client";
import { useEffect, useState, useRef } from "react";
import Image from "next/image";
import { useParams } from "next/navigation";
import {
  fetchMessages,
  fetchConversations,
  sendMessage as sendMessageApi,
} from "@/lib/api/messaging";
import { fetchUserProfile } from "@/lib/api/users";
import { Conversation, Message } from "@/types/messaging";
import { useAuth } from "@/lib/api/authContext";

export default function ConversationPage() {
  const { username } = useParams<{ username: string }>();
  const { user } = useAuth();
  const [conversation, setConversation] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [content, setContent] = useState("");
  const wsRef = useRef<WebSocket | null>(null);
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    if (!username) return;

    const setupConversation = async () => {
      try {
        const allConversations = await fetchConversations();
        const existingConv = allConversations.find(
          (c) => c.username === username
        );

        if (existingConv) {
          setConversation(existingConv);
          const msgs = await fetchMessages(username);
          setMessages(msgs);
          openSocket();
        } else {
          const userProfile = await fetchUserProfile(username);
          const placeholderConv = {
            ...userProfile,
            id: -1,
            last_message: null,
          };
          setConversation(placeholderConv as Conversation);
          setMessages([]);
        }
      } catch (error) {
        console.error(
          "Erreur lors de l'initialisation de la conversation:",
          error
        );
      }
    };

    setupConversation();

    return () => {
      wsRef.current?.close();
    };
  }, [username]);

  function openSocket() {
    const protocol = window.location.protocol === "https:" ? "wss" : "ws";
    const ws = new WebSocket(
      `${protocol}://${window.location.host}/ws/notifications/`
    );
    wsRef.current = ws;
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

      if (conversation.id === -1) {
        const allConversations = await fetchConversations();
        const newConv = allConversations.find((c) => c.username === username);
        if (newConv) {
          setConversation(newConv);
          openSocket();
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
    <div className="flex flex-col h-full bg-base-200">
      <header className="bg-base-100 p-4 text-base-content border-b border-base-300 shadow-sm">
        <h1 className="text-xl font-semibold">
          {conversation.prenom} {conversation.nom}
        </h1>
      </header>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((m) => {
          const isMyMessage = m.expediteur_username === user?.username;

          if (isMyMessage) {
            // User's messages on the right
            return (
              <div key={m.id} className="flex items-end justify-end gap-3">
                <div className="chat-bubble chat-bubble-primary shadow">
                  {m.contenu}
                </div>
                <div className="avatar">
                  <div className="w-9 rounded-full">
                    <Image
                      src={
                        user?.photo_profil
                          ? `http://127.0.0.1:8000/${user.photo_profil}`
                          : `https://ui-avatars.com/api/?name=${user?.prenom}+${user?.nom}&background=random`
                      }
                      alt="My Avatar"
                      height={36}
                      width={36}
                      sizes="220px"
                    />
                  </div>
                </div>
              </div>
            );
          } else {
            // Recipient's messages on the left
            return (
              <div key={m.id} className="flex items-end gap-3">
                <div className="avatar">
                  <div className="w-9 rounded-full">
                    <Image
                      src={
                        conversation.photo_profil ||
                        `https://ui-avatars.com/api/?name=${conversation.prenom}+${conversation.nom}&background=random`
                      }
                      alt="User Avatar"
                      width={36}
                      height={36}
                      sizes="220px"
                    />
                  </div>
                </div>
                <div className="chat-bubble bg-base-100 text-base-content shadow">
                  {m.contenu}
                </div>
              </div>
            );
          }
        })}
        <div ref={messagesEndRef} />
      </div>

      <footer className="bg-base-100 border-t border-base-300 p-4">
        <div className="flex items-center gap-2">
          <input
            type="text"
            placeholder="Type a message..."
            className="input input-bordered w-full"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
              }
            }}
          />
          <button
            className="btn btn-primary"
            onClick={sendMessage}
            disabled={!content.trim()}
          >
            Send
          </button>
        </div>
      </footer>
    </div>
  );
}
