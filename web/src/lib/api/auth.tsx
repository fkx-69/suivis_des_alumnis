import axios from "axios";
import { api } from "./axios";
import {
  LoginPayload,
  LoginResponse,
  StudentRegisterPayload,
  AlumniRegisterPayload,
} from "@/types/auth";
export async function login(data: LoginPayload) {
  const res = await api.post<LoginResponse>("/accounts/login/", data);
  return res.data;
}

export async function registerStudent(data: StudentRegisterPayload) {
  const res = await axios.post(
    "http://127.0.0.1:8000/api/accounts/register/etudiant/",
    data
  );
  return res;
}

export async function registerAlumni(data: AlumniRegisterPayload) {
  const res = await axios.post(
    "http://127.0.0.1:8000/api/accounts/register/alumni/",
    data
  );
  return res;
}

export async function updateProfile(
  data: Record<string, string | File | null | undefined>
) {
  const formData = new FormData();
  Object.entries(data).forEach(([key, value]) => {
    if (value !== undefined && value !== null) {
      formData.append(key, value);
    }
  });

  const res = await api.put("/accounts/me/update/", formData, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  return res.data;
}

export async function changeEmail(data: { email: string }) {
  const res = await api.put("/accounts/change-email/", data);
  return res.data;
}
