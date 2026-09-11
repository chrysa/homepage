#!/usr/bin/env bash
# Rend un *.tmpl.yaml en substituant les ${VAR} depuis l'environnement.
# Aucune valeur en dur : tout vient de l'env (lui-même alimenté par estate.values.yaml).
# Usage : ROOT_DOMAIN=... AUTH_MIDDLEWARE=... ./render.sh <fichier.tmpl.yaml>
set -euo pipefail

tmpl="${1:?usage: render.sh <fichier.tmpl.yaml>}"
[ -f "$tmpl" ] || { echo "introuvable: $tmpl" >&2; exit 1; }

command -v envsubst >/dev/null 2>&1 || {
  echo "envsubst requis (paquet gettext)" >&2; exit 1; }

# N'expose que les variables explicitement attendues, pour ne rien substituer par accident.
vars='${ROOT_DOMAIN} ${CLUSTER_ISSUER} ${INGRESS_CLASS} ${AUTH_MIDDLEWARE}
${SECURITY_MIDDLEWARE} ${ZONE_NAME} ${ZONE_DOMAIN} ${PORTAL_LDAP_GROUP}
${FLEET_ZONE_NAME} ${FLEET_ZONE_DOMAIN} ${FLEET_PATH} ${WIDGET_TOKEN_ENV}'

envsubst "$vars" < "$tmpl"
