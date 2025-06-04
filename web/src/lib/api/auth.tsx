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

export async function registerStudent(data: any) {
  const res = await axios.post(
    "http://127.0.0.1:8000/api/accounts/register/etudiant/",
    data
  );
  return res;
}

export async function registerAlumni(data: any) {
  const res = await axios.post(
    "http://127.0.0.1:8000/api/accounts/register/alumni/",
    data
  );
  return res;
}
