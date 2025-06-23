import { api } from "./axios";
import { Report } from "@/types/report";

export async function createReport(reported_user_id: number, reason: string) {
  const res = await api.post<Report>("/reports/report/", { reported_user_id, reason });
  return res.data;
}

export async function fetchReports() {
  const res = await api.get<Report[]>("/reports/reports/");
  return res.data;
}

export async function banUser(userId: number) {
  await api.post(`/reports/ban/${userId}/`);
}

export async function deleteUser(userId: number) {
  await api.delete(`/reports/delete/${userId}/`);
}
