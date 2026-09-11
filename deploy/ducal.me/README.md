# Homepage — intégration estate `ducal.me`

> Paquet **autonome** (aucun fichier du cœur de Homepage n'est modifié), afin que ce
> fork reste rebasable sur l'upstream sans conflit. Tout vit sous `deploy/ducal.me/`.

Ce dossier documente et outille l'usage de Homepage comme **vitrine d'accès de la
couche maître** d'un cluster **k3s mono-nœud, multi-zones DNS**, gouverné par un
contrat de consommation (GitOps).

## Principe directeur

Homepage n'a **pas d'authentification interne** — et n'en a pas besoin. Le contrôle
d'accès est fait **en amont** :

- **Traefik** est le point d'entrée (TLS, routage d'hôte, redirection).
- Un **forward-auth** adossé à l'**annuaire LDAP** (`dc=ducal,dc=me`) protège chaque
  hôte, **gaté par groupe et par domaine**.
- Homepage lui-même est protégé par la middleware d'auth Traefik.

**Conséquence : ce fork n'ajoute aucun code d'auth/RBAC dans Homepage.** Le porter
dans le code irait contre l'upstream (les mainteneurs ont écarté la gestion
d'utilisateurs) et créerait une dette permanente.

## Comment un service apparaît dans la vitrine — sans PR contre l'infra

Homepage lit les `Ingress` du cluster via son `ClusterRole`. **Chaque produit déclare
sa propre tuile sur son propre `Ingress`**, dans son repo/zone — jamais dans le repo
d'infra. Voir [`ingress-annotations.example.yaml`](./ingress-annotations.example.yaml).

## Contenu

| Fichier | Rôle |
| ------- | ---- |
| `ingress-annotations.example.yaml` | Le patron d'annotations `gethomepage.dev/*` qu'un produit pose sur son `Ingress` pour apparaître + le gate LDAP par groupe. |
| `settings.example.yaml` | Regroupement des tuiles par domaine/couche, thème, titre. |
| `widgets-customapi.example.yaml` | Widget `customapi` : brancher une surface métier (rollup/état) en lecture seule. |

## Frictions connues (à trancher par ADR, pas ici)

1. **Lecture cross-zone.** Le `ClusterRole` lit *tous* les `Ingress` — acceptable tant
   que l'estate est mono-opérateur.
2. **Visibilité non-par-groupe.** Homepage est « tout ou rien » en interne. Pour
   qu'un tiers ne voie que sa zone : **une instance par zone** (gate LDAP distinct),
   pas un filtrage interne (qui n'existe pas).
