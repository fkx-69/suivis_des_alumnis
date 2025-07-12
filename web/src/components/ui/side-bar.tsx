import React, { useState, ReactNode } from "react";
import Link from "next/link";
import { useAuth } from "@/lib/api/authContext";
import { useRouter, usePathname } from "next/navigation";
import ThemeToggle from "./theme-toggle";

import {
  MessageCircleMore,
  CalendarIcon,
  UserCircleIcon,
  LogOutIcon,
  GripHorizontalIcon,
  Menu,
  Users,
  NewspaperIcon,
  BarChart2Icon,
  FileTextIcon,
} from "lucide-react";

const navItems = [
  {
    label: "Acceuil",
    icon: <NewspaperIcon size={20} />,
    href: "/",
  },
  {
    label: "Discussions",
    icon: <MessageCircleMore size={20} />,
    href: "/discussions",
  },
  {
    label: "Groupes",
    icon: <Users size={20} />,
    href: "/groupes",
  },
  {
    label: "Évènements",
    icon: <CalendarIcon size={20} />,
    href: "/evenement",
  },
  {
    label: "Publications",
    icon: <FileTextIcon size={20} />,
    href: "/publications",
  },
  {
    label: "Statistiques",
    icon: <BarChart2Icon size={20} />,
    href: "/statistiques",
  },
];
const profileItems = {
  label: "Profile",
  icon: <UserCircleIcon size={20} />,
  href: "/profile",
};

export default function SidePanel({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(true);
  const panelWidth = collapsed ? "w-16" : "w-50";
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const router = useRouter();

  const visibleNavItems = navItems.filter((item) => {
    if (item.label === "Parcours") {
      return user?.role?.toUpperCase() === "ALUMNI";
    }
    return true;
  });

  const handleLogout = async () => {
    await logout();
    if (typeof window !== "undefined") {
      localStorage.removeItem("token");
    }
    router.push("/auth/login");
  };

  return (
    <div className="drawer md:drawer-open h-screen">
      <input id="side-panel-drawer" type="checkbox" className="drawer-toggle" />
      <div className="drawer-content flex flex-col overflow-hidden">
        <header className="navbar bg-base-200 md:hidden">
          <label
            htmlFor="side-panel-drawer"
            className="btn btn-ghost btn-square"
          >
            <Menu size={20} />
          </label>
        </header>
        <main className="relative flex-1 overflow-y-auto">{children}</main>
      </div>
      <div className="drawer-side">
        <label
          htmlFor="side-panel-drawer"
          className="drawer-overlay md:hidden"
        ></label>
        <aside
          className={`${panelWidth} bg-base-300 border-r border-base-300 flex flex-col justify-between transition-all duration-300 h-full`}
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
              {visibleNavItems.map((item) => (
                <li
                  key={item.href}
                  className={
                    pathname === item.href
                      ? "bg-primary text-primary-content rounded-md"
                      : "hover:bg-base-300 rounded-md"
                  }
                >
                  <Link
                    href={item.href}
                    className={`flex items-center p-2 w-full btn-primary ${collapsed ? "justify-center" : "gap-3"}`}
                  >
                    {item.icon}
                    {!collapsed && (
                      <span className="text-content">{item.label}</span>
                    )}
                  </Link>
                </li>
              ))}
              <li
                className={
                  pathname === "/profile"
                    ? "bg-primary text-primary-content rounded-md"
                    : "hover:bg-base-300 rounded-md"
                }
              >
                <Link
                  href="/profile"
                  className={`flex items-center p-2 w-full ${collapsed ? "justify-center" : "gap-3"}`}
                >
                  {profileItems.icon}
                  {!collapsed && <span className="text-content">Profile</span>}
                </Link>
              </li>
            </ul>
          </div>
          <div className="p-2 flex flex-col gap-2">
            <ThemeToggle collapsed={collapsed} />
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
