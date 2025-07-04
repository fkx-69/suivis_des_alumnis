"use client";
import { useEffect, useState, useRef } from 'react';
import { useParams } from 'next/navigation';
import { fetchGroups, fetchGroupMessages, sendGroupMessage } from '@/lib/api/group';
import { Group, GroupMessage } from '@/types/group';
import { useAuth } from '@/lib/api/authContext';
import { Send } from 'lucide-react';
import { formatTimeAgo } from '@/lib/utils';

export default function GroupeDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const [group, setGroup] = useState<Group | null>(null);
  const [messages, setMessages] = useState<GroupMessage[]>([]);
  const [content, setContent] = useState('');
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
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
      setContent('');
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
    <main className="flex h-screen flex-col">
      <header className="flex items-center gap-4 border-b bg-base-100 p-4 shadow-sm">
        <div className="avatar placeholder">
          <div className="w-12 rounded-full bg-neutral-focus text-neutral-content">
            <span>{group.nom_groupe.substring(0, 2)}</span>
          </div>
        </div>
        <h1 className="text-xl font-bold">{group.nom_groupe}</h1>
      </header>

      <div className="flex-1 overflow-y-auto bg-base-200 p-4">
        <div className="space-y-4">
          {messages.map((m) => {
            const isCurrentUser = user.username === m.auteur;
            return (
              <div key={m.id} className={`chat ${isCurrentUser ? 'chat-end' : 'chat-start'}`}>
                <div className="chat-image avatar">
                  <div className="w-10 rounded-full">
                    <img src={`https://ui-avatars.com/api/?name=${m.auteur}&background=random`} alt={m.auteur} />
                  </div>
                </div>
                <div className="chat-header">
                  {m.auteur}
                  <time className="ml-2 text-xs opacity-50">
                    {formatTimeAgo(m.date_envoi)}
                  </time>
                </div>
                <div className="chat-bubble bg-primary">{m.contenu}</div>
              </div>
            );
          })}
          <div ref={messagesEndRef} />
        </div>
      </div>

      <footer className="mt-auto border-t bg-base-100 p-4">
        <form onSubmit={handleSend} className="flex items-center gap-2">
          <input
            type="text"
            className="input input-bordered flex-1"
            placeholder="Écrire un message..."
            value={content}
            onChange={(e) => setContent(e.target.value)}
          />
          <button type="submit" className="btn btn-primary btn-square" disabled={!content.trim()}>
            <Send size={20} />
          </button>
        </form>
      </footer>
    </main>
  );
}
