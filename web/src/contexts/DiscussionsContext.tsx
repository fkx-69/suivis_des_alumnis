import React, { createContext, useContext, useState, useCallback } from "react";
import { Conversation } from "@/types/messaging";

interface DiscussionsContextType {
  conversations: Conversation[];
  setConversations: React.Dispatch<React.SetStateAction<Conversation[]>>;
  addConversation: (conv: Conversation) => void;
}

const DiscussionsContext = createContext<DiscussionsContextType | undefined>(undefined);

export const DiscussionsProvider = ({ children }: { children: React.ReactNode }) => {
  const [conversations, setConversations] = useState<Conversation[]>([]);

  const addConversation = useCallback((conv: Conversation) => {
    setConversations((prev) => {
      // Si déjà présent, on le met en haut
      const filtered = prev.filter((c) => c.username !== conv.username);
      return [conv, ...filtered];
    });
  }, []);

  return (
    <DiscussionsContext.Provider value={{ conversations, setConversations, addConversation }}>
      {children}
    </DiscussionsContext.Provider>
  );
};

export function useDiscussions() {
  const ctx = useContext(DiscussionsContext);
  if (!ctx) throw new Error("useDiscussions must be used within DiscussionsProvider");
  return ctx;
} 