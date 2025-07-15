export const niveau_etude = {
  L1 : "Licence 1",
  L2 : "Licence 2",
  L3 : "Licence 3",
  M1 : "Master 1",
  M2 : "Master 2",
};

export const niveau_etude_keys = Object.keys(niveau_etude) as (keyof typeof niveau_etude)[];

export const Mentions = {
  mention_passable : "Passable",
  mention_assez_bien : "Assez bien",
  mention_bien: "Bien",
  mention_tres_bien : "Très bien" };

export const Mention_keys = Object.keys(Mentions) as (keyof typeof Mentions)[];