"use client";

import React, { useState, ReactNode, useEffect, useRef, act } from "react";
import PersonalProfile from "./personal-profile";
import { useAuth } from "@/lib/api/authContext";
import { useRouter } from "next/navigation";

import {
  HomeIcon,
  MessageCircleMore,
  CalendarIcon,
  UserCircleIcon,
  SettingsIcon,
  LogOutIcon,
  GripHorizontalIcon,
  Users,
} from "lucide-react";

const navItems = [
  {
    label: "Updates",
    icon: <HomeIcon size={20} />,
    href: "/",
    active: true,
  },
  {
    label: "Discussions",
    icon: <MessageCircleMore size={20} />,
    href: "/discussions",
    active: false,
  },
  {
    label: "Events",
    icon: <CalendarIcon size={20} />,
    href: "/evenement",
    active: false,
  },
  {
    label: "Mentorat",
    icon: <Users size={20} />,
    href: "/mentorat",
    active: false,
  },
  {
    label: "Membres",
    icon: <Users size={20} />,
    href: "/usersList",
    active: false,
  },
];
const profileItems = {
  label: "Profile",
  icon: <UserCircleIcon size={20} />,
  href: "#",
  active: false,
};

export default function SidePanel({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const panelWidth = collapsed ? "w-16" : "w-50";

  const { logout } = useAuth();
  const router = useRouter();

  const handleLogout = async () => {
    await logout();
    if (typeof window !== "undefined") {
      localStorage.removeItem("token");
    }
    router.push("/auth/login");
  };

  const profileButtonRef = useRef<HTMLButtonElement>(null);

  const handleCloseProfile = () => {
    setShowProfile(false);
  };

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        profileButtonRef.current &&
        profileButtonRef.current.contains(event.target as Node)
      ) {
        return;
      }
    }

    if (showProfile) {
      document.addEventListener("mousedown", handleClickOutside);
    } else {
      document.removeEventListener("mousedown", handleClickOutside);
    }
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [showProfile]);

  return (
    <div className="flex flex-auto h-screen overflow-hidden">
      <aside
        className={`${panelWidth} bg-base-200 border-r border-base-200 flex flex-col justify-between transition-all duration-300`}
      >
        <div>
          <div
            className={
              collapsed ? "flex justify-center p-2" : "flex justify-end p-2"
            }
          >
            <button
              onClick={() => setCollapsed((c) => !c)}
              className="btn btn-ghost btn-sm"
            >
              <GripHorizontalIcon size={20} />
            </button>
          </div>

          <ul className="menu p-2 space-y-1">
            {navItems.map((item) => (
              <li
                key={item.label}
                className={
                  item.active
                    ? "bg-primary text-primary-content rounded-md"
                    : "hover:bg-base-300 rounded-md"
                }
              >
                <a
                  href={item.href}
                  className={`flex items-center p-2 w-full btn-primary   /* <= nouveau */
                ${collapsed ? "justify-center" : "gap-3"}   
                `}
                  onClick={() => showProfile && setShowProfile(false)}
                >
                  {item.icon}
                  {!collapsed && (
                    <span className="text-content">{item.label}</span>
                  )}
                </a>
              </li>
            ))}
            <li>
              <button
                ref={profileButtonRef}
                className={`flex items-center p-2 w-full   /* <= nouveau */
                ${
                  collapsed ? "justify-center" : "gap-3"
                } hover:bg-base-300 rounded-md`}
                onClick={() => setShowProfile((prev) => !prev)}
                aria-haspopup="true"
                aria-expanded={showProfile}
              >
                {profileItems.icon}
                {!collapsed && <span className="text-content">Profile</span>}
              </button>
            </li>
          </ul>
        </div>
        <div className="p-2">
          <button
            onClick={handleLogout}
            className={`flex items-center p-2 w-full hover:bg-base-300 rounded-md ${
              collapsed ? "justify-center" : "gap-3"
            }`}
          >
            <LogOutIcon size={20} />
            {!collapsed && <span className="text-content">Déconnexion</span>}
          </button>
        </div>
      </aside>
      <main className="relative flex-1 overflow-auto">
        {showProfile && <PersonalProfile onClose={handleCloseProfile} />}
        {children}
      </main>
    </div>
  );
}
