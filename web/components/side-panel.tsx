"use client";

import React, { useState, useEffect, useRef, ReactNode } from "react";
import PersonalProfile from "./personal-profile";

import {
  HomeIcon,
  UsersIcon,
  CalendarIcon,
  UserCircleIcon,
  SettingsIcon,
  LogOutIcon,
  GripHorizontalIcon,
} from "lucide-react";

const navItems = [
  {
    label: "Updates",
    icon: <HomeIcon size={20} />,
    href: "#",
    active: true,
  },
  { label: "Groups", icon: <UsersIcon size={20} />, href: "#" },
  { label: "Events", icon: <CalendarIcon size={20} />, href: "#" },
];
const profileItems = {
  label: "Profile",
  icon: <UserCircleIcon size={20} />,
  href: "#",
};

const bottomItems = [
  { label: "Settings", icon: <SettingsIcon size={20} />, href: "#" },
  { label: "Sign Out", icon: <LogOutIcon size={20} />, href: "#" },
];

export default function SidePanel({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const [showProfile, setShowProfile] = useState(false);

  const panelWidth = collapsed ? "w-16" : "w-40";

  const profileButtonRef = useRef<HTMLLIElement>(null);
  const profilePopoverRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        profilePopoverRef.current &&
        !profilePopoverRef.current.contains(event.target as Node) &&
        profileButtonRef.current &&
        !profileButtonRef.current.contains(event.target as Node)
      ) {
        setShowProfile(false);
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
    <div className="flex h-screen bg-amber-50">
      <aside
        className={`${panelWidth} bg-base-200 border-r border-gray-200 flex flex-col justify-between transition-all duration-300`}
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
                  className={`flex items-center gap-3 p-2 ${
                    collapsed ? "justify-center" : ""
                  }`}
                  onClick={() => setShowProfile(false)}
                >
                  {item.icon}
                  {!collapsed && <span className="text-sm">{item.label}</span>}
                </a>
              </li>
            ))}
            <li
              ref={profileButtonRef}
              className="relative hover:bg-base-300 rounded-md"
            >
              <button
                className={`flex items-center gap-3 p-2 w-full ${
                  collapsed ? "justify-center" : ""
                }`}
                onClick={() => setShowProfile((prev) => !prev)}
                aria-haspopup="true"
                aria-expanded={showProfile}
              >
                {profileItems.icon}
                {!collapsed && <span className="text-sm">Profile</span>}
              </button>
              {showProfile && (
                <div
                  ref={profilePopoverRef}
                  className={`absolute top-0 ${
                    collapsed ? "left-full ml-2" : "left-full ml-2"
                  } z-20 bg-white rounded-lg shadow-xl border border-gray-200 w-80`}
                >
                  <div className="max-h-[80vh] overflow-auto p-1">
                    <PersonalProfile />
                  </div>
                </div>
              )}
            </li>
          </ul>
        </div>

        <ul className="menu p-2 space-y-1 mb-2">
          {bottomItems.map((item) => (
            <li key={item.label} className="hover:bg-base-300 rounded-md">
              <a
                href={item.href}
                className={`flex items-center gap-3 p-2 ${
                  collapsed ? "justify-center" : ""
                }`}
              >
                {item.icon}
                {!collapsed && <span className="text-sm">{item.label}</span>}
              </a>
            </li>
          ))}
        </ul>
      </aside>

      <main className="flex-1 overflow-auto">{children}</main>
    </div>
  );
}
