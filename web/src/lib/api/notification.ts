import { api } from "./axios";
import { Notification } from "@/types/notification";

export async function fetchNotifications() {
  const res = await api.get<Notification[]>("/notifications/");
  return res.data;
}

export function openNotificationSocket(onMessage: (n: Notification) => void) {
  if (typeof window === "undefined") return null;
  const protocol = window.location.protocol === "https:" ? "wss" : "ws";
  const ws = new WebSocket(`${protocol}://${window.location.host}/ws/notifications/`);
  ws.onmessage = (ev) => {
    const data = JSON.parse(ev.data) as { notification: Notification };
    onMessage(data.notification);
  };
  return ws;
}
