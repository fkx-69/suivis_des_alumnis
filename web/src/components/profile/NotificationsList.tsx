"use client";

import { useEffect, useState } from "react";
import { fetchNotifications, openNotificationSocket } from "@/lib/api/notification";
import { Notification } from "@/types/notification";

export default function NotificationsList() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    fetchNotifications().then(setNotifications);
    const ws = openNotificationSocket((n) =>
      setNotifications((prev) => [n, ...prev])
    );
    return () => ws?.close();
  }, []);

  return (
    <div className="space-y-4">
      <h2 className="text-xl font-semibold">Dernières notifications</h2>
      {notifications.length > 0 ? (
        <ul className="space-y-2">
          {notifications.map((n) => (
            <li key={n.id} className="p-3 bg-base-200 rounded-lg shadow-sm">
              {n.message}
            </li>
          ))}
        </ul>
      ) : (
        <p className="text-base-content/70">Vous n&apos;avez aucune nouvelle notification.</p>
      )}
    </div>
  );
}
