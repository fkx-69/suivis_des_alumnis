import axios from "axios";

export function registerUser(data: object) {
  return axios.post("/api/register", JSON.stringify(data));
}

export async function loginUser(data: object) {
  const reponse = await axios.post(
    "http://127.0.0.1:8000/api/accounts/login/",
    data
  );
  console.log(reponse.data);
  return reponse.data;
}
