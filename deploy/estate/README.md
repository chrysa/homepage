# Homepage — intégration estate (multi-domaines, rien en dur)

> Paquet **autonome** (aucun fichier du cœur de Homepage n'est modifié) et
> **domain-agnostic** : aucun nom de domaine, d'hôte ou de token n'est écrit en dur.
> Tout paramètre vient de `estate.values.example.yaml` (ou de l'environnement) et est
> rendu au déploiement. Le fork reste rebasable sur l'upstream.

Ce dossier outille Homepage comme **vitrine d'accès de la couche maître** d'un cluster
**k3s multi-zones DNS**, gouverné par un contrat de consommation (GitOps).

## Rien en dur — d'où viennent les valeurs

| Paramètre | Placeholder | Source |
| --------- | ----------- | ------ |
| Domaine racine (délégations) | `${ROOT_DOMAIN}` | valeurs / env |
| Zones produit (0..N) | `zones[]` | `estate.values.yaml` |
| Hôte d'un service | `${SERVICE_HOST}` | `Ingress` du produit |
| Middleware auth | `${AUTH_MIDDLEWARE}` | contrat d'infra |
| Groupe LDAP de gate | `${LDAP_GROUP}` | contrat d'infra |
| Token widget | `${WIDGET_TOKEN_ENV}` | `Secret` monté, jamais en clair |

**Il n'y a aucun `*.tld` dans les fichiers versionnés.** Un domaine d'exemple
n'apparaît que dans `estate.values.example.yaml`, explicitement marqué comme exemple.

## Rendu

Les `*.tmpl.yaml` sont rendus avec les valeurs, au choix :

- **envsubst** — `render.sh` remplace `${VAR}` depuis l'environnement/les valeurs ;
- **Helm** — les mêmes clés alimentent un `values.yaml` côté chart d'infra.

```sh
# exemple local, sans rien coder en dur :
ROOT_DOMAIN=example.test \
AUTH_MIDDLEWARE=infra-forwardauth-auth@kubernetescrd \
  ./render.sh ingress-annotations.tmpl.yaml
```

## Multi-domaines

`estate.values.yaml` liste **N zones**. Chaque zone porte son domaine, son groupe LDAP
de gate et, si besoin, sa propre **instance de vitrine** (pour lever la friction de
visibilité par tiers). Ajouter un domaine = ajouter une entrée `zones[]`, aucune autre
édition.

## Principe d'accès (inchangé)

Homepage n'a pas d'auth interne : **Traefik** forward-auth + **annuaire LDAP** gèrent
l'accès en amont, gaté par groupe et par zone. Ce paquet n'ajoute aucun code d'auth/RBAC.

## Frictions connues (à trancher par ADR)

1. **Lecture cross-zone** — le `ClusterRole` lit *tous* les `Ingress` (OK mono-opérateur).
2. **Visibilité non-par-groupe** — pour isoler un tiers : **une instance par zone**
   (`portalInstances[]` dans les valeurs), pas un filtrage interne.
