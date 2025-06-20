"use client";
import { useEffect, useState } from "react";
import { fetchNotifications, openNotificationSocket } from "@/lib/api/notification";
import { Notification } from "@/types/notification";

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    fetchNotifications().then(setNotifications);
    const ws = openNotificationSocket((n) =>
      setNotifications((prev) => [n, ...prev])
    );
    return () => ws?.close();
  }, []);

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 space-y-2">
      <h1 className="text-2xl font-semibold">Notifications</h1>
      <ul className="space-y-2">
        {notifications.map((n) => (
          <li key={n.id} className="p-2 bg-base-200 rounded-md">
            {n.message}
          </li>
        ))}
      </ul>
    </main>
  );
}
