"use client";
import React, { useState, useEffect, useRef } from "react";
import Image from "next/image";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { fetchConversations } from "@/lib/api/messaging";
import { Conversation } from "@/types/messaging";
import { useAuth } from "@/lib/api/authContext";
import { useProfileModal } from "@/contexts/ProfileModalContext";

export default function DiscussionsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
    const { user } = useAuth();
  const { showProfile } = useProfileModal();

  const handleProfileClick = (e: React.MouseEvent, username: string) => {
    e.stopPropagation();
    e.preventDefault();
    showProfile(username);
  };
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);
  
  const menuDropdownRef = React.useRef<HTMLDivElement>(null);
  const menuButtonRef = React.useRef<HTMLButtonElement>(null);

  useEffect(() => {
    fetchConversations()
      .then(setConversations)
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    const menuButton = menuButtonRef.current;
    const menuDropdown = menuDropdownRef.current;

    if (!menuButton || !menuDropdown) return;

    const handleMenuClick = () => {
      menuDropdown.classList.toggle('hidden');
    };

    const handleClickOutside = (event: MouseEvent) => {
      if (
        menuDropdown &&
        !menuDropdown.contains(event.target as Node) &&
        menuButton &&
        !menuButton.contains(event.target as Node)
      ) {
        menuDropdown.classList.add('hidden');
      }
    };

    menuButton.addEventListener('click', handleMenuClick);
    document.addEventListener('click', handleClickOutside);

    return () => {
      menuButton.removeEventListener('click', handleMenuClick);
      document.removeEventListener('click', handleClickOutside);
    };
  }, []);

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Sidebar */}
      <div className="w-1/4 bg-base-100 border-r border-base-300 flex flex-col">
        {/* Sidebar Header */}
        <header className="p-4 border-b border-base-300 flex justify-between items-center bg-primary text-primary-content">
          <h1 className="text-2xl font-semibold">Discussions</h1>
        </header>

        {/* Contact List */}
        <div className="overflow-y-auto h-full p-3">
          {loading ? (
            <div className="flex justify-center items-center h-full">
              <p>Chargement des conversations...</p>
            </div>
          ) : (
            conversations.map((conv) => {
              const isActive = pathname === `/discussions/${conv.username}`;
              return (
                <Link key={conv.id} href={`/discussions/${conv.username}`}>
                  <div className={`flex items-center mb-4 cursor-pointer p-2 rounded-md ${isActive ? "bg-base-300" : "hover:bg-base-200"}`}>
                    <div className="w-12 h-12 bg-gray-300 rounded-full mr-3 overflow-hidden cursor-pointer" onClick={(e) => handleProfileClick(e, conv.username)} >
                      <Image
                        src={conv.photo_profil || `https://ui-avatars.com/api/?name=${conv.prenom}+${conv.nom}&background=random`}
                        alt="User Avatar"
                        width={48}
                        height={48}
                        className="w-12 h-12 rounded-full"
                        unoptimized
                      />
                    </div>
                    <div className="flex-1 overflow-hidden">
                      <p 
                        className="font-semibold cursor-pointer hover:underline transition-all duration-200" 
                        onClick={(e) => handleProfileClick(e, conv.username)}
                      >
                        {conv.prenom} {conv.nom}
                      </p>
                      <p className="text-base-content/70 truncate">
                        {conv.last_message ? conv.last_message : <span className="italic">Aucun message</span>}
                      </p>
                    </div>
                  </div>
                </Link>
              );
            })
          )}
        </div>
      </div>

      {/* Main Chat Area */}
      <main className="flex-1 h-full overflow-y-auto">
        {children}
      </main>
      
    </div>
  );
}
