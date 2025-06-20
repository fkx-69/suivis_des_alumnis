"use client";

import React, { useState, ReactNode, useEffect, useRef } from "react";
import PersonalProfile from "./personal-profile";
import { useAuth } from "@/lib/api/authContext";
import { useRouter, usePathname } from "next/navigation";
import ThemeToggle from "./theme-toggle";

import {
  HomeIcon,
  MessageCircleMore,
  CalendarIcon,
  UserCircleIcon,
  LogOutIcon,
  GripHorizontalIcon,
  Menu,
  Users,
  NewspaperIcon,
  BellIcon,
  BarChart2Icon,
  FileWarningIcon,
  MapIcon,
  FileTextIcon,
} from "lucide-react";

const navItems = [
  {
    label: "Actualités",
    icon: <NewspaperIcon size={20} />,
    href: "/",
  },
  {
    label: "Discussions",
    icon: <MessageCircleMore size={20} />,
    href: "/discussions",
  },
  {
    label: "Évènements",
    icon: <CalendarIcon size={20} />,
    href: "/evenement",
  },
  {
    label: "Mentorat",
    icon: <Users size={20} />,
    href: "/mentorat",
  },
  {
    label: "Filières",
    icon: <Users size={20} />,
    href: "/filiere",
  },
  {
    label: "Publications",
    icon: <FileTextIcon size={20} />,
    href: "/publications",
  },
  {
    label: "Notifications",
    icon: <BellIcon size={20} />,
    href: "/notifications",
  },
  {
    label: "Statistiques",
    icon: <BarChart2Icon size={20} />,
    href: "/statistiques",
  },
  {
    label: "Rapports",
    icon: <FileWarningIcon size={20} />,
    href: "/reports",
  },
  {
    label: "Parcours",
    icon: <MapIcon size={20} />,
    href: "/parcours",
  },
  {
    label: "Membres",
    icon: <Users size={20} />,
    href: "/usersList",
  },
];
const profileItems = {
  label: "Profil",
  icon: <UserCircleIcon size={20} />,
  href: "#",
};

export default function SidePanel({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const panelWidth = collapsed ? "w-16" : "w-50";

  const pathname = usePathname();

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
    <div className="drawer md:drawer-open h-screen">
      <input id="side-panel-drawer" type="checkbox" className="drawer-toggle" />
      <div className="drawer-content flex flex-col">
        <header className="navbar bg-base-200 md:hidden">
          <label htmlFor="side-panel-drawer" className="btn btn-ghost btn-square">
            <Menu size={20} />
          </label>
        </header>
        <main className="relative flex-1 overflow-auto">
          {showProfile && <PersonalProfile onClose={handleCloseProfile} />}
          {children}
        </main>
      </div>
      <div className="drawer-side">
        <label htmlFor="side-panel-drawer" className="drawer-overlay md:hidden"></label>
        <aside
          className={`${panelWidth} bg-base-200 border-r border-base-200 flex flex-col justify-between transition-all duration-300`}
        >
          <div>
            <div className={collapsed ? "flex justify-center p-2" : "flex justify-end p-2"}>
              <button onClick={() => setCollapsed((c) => !c)} className="btn btn-ghost btn-sm">
                <GripHorizontalIcon size={20} />
              </button>
            </div>
            <ul className="menu p-2 space-y-1">
              {navItems.map((item) => (
                <li
                  key={item.label}
                  className={
                    pathname === item.href
                      ? "bg-primary text-primary-content rounded-md"
                      : "hover:bg-base-300 rounded-md"
                  }
                >
                  <a
                    href={item.href}
                    className={`flex items-center p-2 w-full btn-primary ${collapsed ? "justify-center" : "gap-3"}`}
                    onClick={() => showProfile && setShowProfile(false)}
                  >
                    {item.icon}
                    {!collapsed && <span className="text-content">{item.label}</span>}
                  </a>
                </li>
              ))}
              <li>
                <button
                  ref={profileButtonRef}
                  className={`flex items-center p-2 w-full ${collapsed ? "justify-center" : "gap-3"} hover:bg-base-300 rounded-md`}
                  onClick={() => setShowProfile((prev) => !prev)}
                  aria-haspopup="true"
                  aria-expanded={showProfile}
                >
                  {profileItems.icon}
                  {!collapsed && <span className="text-content">Profil</span>}
                </button>
              </li>
            </ul>
          </div>
          <div className="p-2 flex flex-col gap-2">
            <ThemeToggle />
            <button
              onClick={handleLogout}
              className={`flex items-center p-2 w-full hover:bg-base-300 rounded-md ${collapsed ? "justify-center" : "gap-3"}`}
            >
              <LogOutIcon size={20} />
              {!collapsed && <span className="text-content">Déconnexion</span>}
            </button>
          </div>
        </aside>
      </div>
    </div>
  );
}
