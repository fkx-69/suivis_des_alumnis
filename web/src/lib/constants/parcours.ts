export const Mentions = {
  mention_passable: "Passable",
  mention_assez_bien: "Assez bien",
  mention_bien: "Bien",
  mention_tres_bien: "Très bien",
} as const;

export type Mention = keyof typeof Mentions;
