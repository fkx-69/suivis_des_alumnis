export const jobBySector = {
  "Marketing et Ventes": {
    "chef_produit": "Chef de produit",
    "responsable_marketing": "Responsable marketing",
    "commercial_terrain": "Commercial terrain",
    "category_manager": "Category manager",
    "chef_ventes": "Chef des ventes",
  },
  "Ressources Humaines": {
    "charge_recrutement": "Chargé de recrutement",
    "gestionnaire_paie": "Gestionnaire de paie",
    "responsable_formation": "Responsable formation",
    "charge_relations_sociales": "Chargé des relations sociales",
    "consultant_rh": "Consultant RH",
  },
  "Comptabilité Finance": {
    "comptable_general": "Comptable général",
    "controleur_gestion": "Contrôleur de gestion",
    "auditeur_financier": "Auditeur financier",
    "analyste_financier": "Analyste financier",
    "tresorier_entreprise": "Trésorier d’entreprise",
  },
  "Marketing Digital": {
    "community_manager": "Community manager",
    "traffic_manager": "Traffic manager",
    "seo_sea_manager": "SEO/SEA manager",
    "growth_hacker": "Growth hacker",
    "responsable_emailing": "Responsable e-mailing",
  },
  "Communication": {
    "charge_communication": "Chargé de communication",
    "attache_presse": "Attaché de presse",
    "directeur_communication": "Directeur de la communication",
    "concepteur_redacteur": "Concepteur-rédacteur",
    "event_manager": "Event manager",
  },
  "Logistique et Transport": {
    "responsable_logistique": "Responsable logistique",
    "planificateur_transport": "Planificateur transport",
    "gestionnaire_entrepot": "Gestionnaire d’entrepôt",
    "chef_quai": "Chef de quai",
    "coordinateur_supply_chain": "Coordinateur supply chain",
  },
  "Informatique, Réseaux et Télécommunications": {
    "admin_systeme_reseaux": "Administrateur systèmes et réseaux",
    "ingenieur_telecoms": "Ingénieur télécoms",
    "developpeur_logiciel": "Développeur logiciel",
    "ingenieur_cybersecurite": "Ingénieur cybersécurité",
    "architecte_cloud": "Architecte cloud",
    "data_analyst": "Data Analyst",
    "developpeur_web": "Développeur Web",
    "ingenieur_data": "Ingénieur Data",
    "chef_de_projet": "Chef de projet",
  },
  "Relations Internationales & Diplomatie": {
    "attache_diplomatique": "Attaché diplomatique",
    "charge_mission_internationale": "Chargé de mission internationale",
    "analyste_geopolitique": "Analyste géopolitique",
    "coordinateur_ong": "Coordinateur ONG",
    "conseiller_ri": "Conseiller en relations publiques internationales",
  },
  "Autres": {
    "autres": "Autres",
  },
};

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