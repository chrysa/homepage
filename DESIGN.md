# homepage (estate fork) — Design contract

> Contract for this fork's **configuration** of [Homepage](https://github.com/gethomepage/homepage):
> the estate access portal described in [deploy/estate](deploy/estate/README.md). Upstream
> owns the application UI (`src/`, themes, components); this file does not document or
> redesign it. Read it before changing the estate templates, the dashboard layout or the
> widgets; update it in the same change. Status: **[implemented]** links the file ·
> **[decided]** names the decision · **[proposed]** is not agreed.

## 1. Surface and status

- **Surface:** configured dashboard — Homepage settings, service tiles discovered from
  Kubernetes Ingress annotations, and one status widget, all as templates. **[implemented]**
  ([settings.tmpl.yaml](deploy/estate/settings.tmpl.yaml),
  [ingress-annotations.tmpl.yaml](deploy/estate/ingress-annotations.tmpl.yaml),
  [widgets-customapi.tmpl.yaml](deploy/estate/widgets-customapi.tmpl.yaml))
- **Lifecycle:** prototype — templates and an example values file only; no rendered instance
  or real values are versioned here ([estate.values.example.yaml](deploy/estate/estate.values.example.yaml)).
- **Detailed specs:** [deploy/estate/README.md](deploy/estate/README.md) (rendering,
  multi-domain model, known frictions). Upstream configuration reference: [docs/configs](docs/configs/index.md).

## 2. Users, devices and priority tasks

| User                                       | Context and device                           | Priority tasks (three at most)                                                       |
| ------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| Estate operator or member of an LDAP group | desktop browser, behind Traefik forward-auth | find and open a product · see whether a product is up · read the fleet audit summary |
| Operator adding a product domain           | values file, shell                           | add a zone · render the templates                                                    |

Primary action: open a product tile in the _Produits_ group.

## 3. Journeys and navigation

- **J1 — Open a product:** sign in upstream (Traefik + LDAP) → the portal lists products in
  _Produits_, discovered from `gethomepage.dev/*` annotations on each product's Ingress → a click
  opens the product in a new tab (`target: _blank`); `siteMonitor` shows whether it answers.
  **[implemented]** (templates)
- **J2 — Read audit status:** the _Audit_ group holds a `customapi` widget with three fields
  (_Projets_, _Findings hauts_, _Conformité_), refreshed every 60 s; its token comes from a
  Secret through an environment variable, never from the values file. **[implemented]**
  ([widgets-customapi.tmpl.yaml](deploy/estate/widgets-customapi.tmpl.yaml))
- **J3 — Add a domain:** add a `zones[]` entry → render with
  [render.sh](deploy/estate/render.sh) (envsubst, an explicit variable list) → the product's
  Ingress carries the tile. **[implemented]**
- **Information architecture:** title `Estate ${ROOT_DOMAIN}`; groups _Infra_ and _Produits_
  as rows of four columns; one portal instance per LDAP tier to isolate visibility —
  **[proposed]**, listed as a friction to settle by ADR in
  [deploy/estate/README.md](deploy/estate/README.md).
- **Density:** comfortable tiles, four per row.

## 4. Identity

- **Brand brief:** none. The portal uses upstream's `theme: dark`, `color: slate`,
  `headerStyle: clean`. **[implemented]** ([settings.tmpl.yaml](deploy/estate/settings.tmpl.yaml))
- **Why it fits:** an internal access portal; recognisable product names matter more than a
  brand, and staying on upstream styles keeps the fork rebasable.
- **Signature element:** none today. A teal-accent overlay with amber offline signals and a
  visible focus ring was added in commit `1749dd39` and deleted in `f49b7459`; it was not
  carried into `deploy/estate`.
- **Rule:** customisation goes through settings and mounted config files, never through
  `src/` edits. **[decided]** ([deploy/estate/README.md](deploy/estate/README.md): no core file
  is modified)

## 5. Tokens and components (owned elsewhere)

| Concern                           | Source of truth                                                                        | Rules of use                                                                      |
| --------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Colour, type, spacing, components | upstream ([theme.css](src/styles/theme.css), [tailwind.config.js](tailwind.config.js)) | select through `theme` and `color` in settings; do not edit                       |
| Layout                            | `layout` in [settings.tmpl.yaml](deploy/estate/settings.tmpl.yaml)                     | one entry per group, `style: row`, `columns: 4`                                   |
| Values                            | [estate.values.example.yaml](deploy/estate/estate.values.example.yaml)                 | the only place for domains and groups; examples use `.test`                       |
| Custom CSS                        | none                                                                                   | upstream supports `customCSS` ([custom-css-js.md](docs/configs/custom-css-js.md)) |

- **Shared contract:** `contract.css` and `@chrysa/ui` are not used; upstream's styles apply.

## 6. Interaction and states

- **Action feedback, forms, component states:** upstream behaviour; the fork adds none.
- **Data states:**

  | State                         | Where it appears | Behaviour                                                                                                                |
  | ----------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------ |
  | Loading                       | tiles, widget    | upstream placeholders                                                                                                    |
  | Empty                         | _Infra_ group    | declared in the layout, but no template fills it                                                                         |
  | Error                         | audit widget     | upstream error container ([component.jsx](src/widgets/customapi/component.jsx)); a missing token variable fails the call |
  | Offline / backend unreachable | tiles            | `siteMonitor` status per product (upstream)                                                                              |
  | Stale data                    | audit widget     | refreshed every 60 s; the age of the figures is not shown                                                                |
  | Reconnect                     | widget           | next refresh                                                                                                             |

- **Real-time:** polling only (`refreshInterval: 60000`).
- **Motion:** upstream's; the fork adds none.

## 7. Responsive and support conventions

Upstream's responsive layout applies; four columns per row reflow on narrow screens (not
verified for this configuration). Do not impose a custom shell or navigation on Homepage.

## 8. Accessibility

- **Target:** WCAG 2.1 AA for web content (canon floor); upstream owns the markup.
- **Keyboard and focus:** upstream defaults; the removed overlay was the only fork-level focus
  rule.
- **Perception and language:** widget labels and group names are French while `settings` sets
  no `language`, so upstream strings follow the default: the page may mix two languages.
- **Assistive technology:** not tested.

## 9. Assets

| Asset                                   | Source or generator                                                                                                                   | Author                                       | Licence and attribution                  | Permitted use | Formats and variants | Location   |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- | ---------------------------------------- | ------------- | -------------------- | ---------- |
| `si-checkmarx` icon on the _Audit_ tile | Simple Icons, fetched at runtime from `cdn.jsdelivr.net` (`simple-icons@latest`, [resolvedicon.jsx](src/components/resolvedicon.jsx)) | Simple Icons contributors; mark of Checkmarx | not recorded in the repository (unknown) | service icon  | SVG                  | remote CDN |

No font, image or logo is added by the fork. Upstream assets and code: [GPL-3.0](LICENSE).

## 10. Acceptance criteria and evidence

- **Criteria:** rendered templates contain no hard-coded domain or token; each product Ingress
  with the annotations yields one tile in _Produits_ that opens the product; the audit widget
  shows three labelled values or an error; access is refused upstream without the LDAP group.
- **Evidence log:**

  | Date       | Change                         | Checks run (tool, sizes, modes) | Result             | Not run, and why                          |
  | ---------- | ------------------------------ | ------------------------------- | ------------------ | ----------------------------------------- |
  | 2026-11-08 | contract written from the code | source review                   | gaps listed in §11 | no browser run: documentation-only change |

## 11. Open choices, known gaps and maintenance

- **Open choices:**
  - **[proposed]** restore the focus-visible and offline-signal overlay as a `customCSS` file in
    `deploy/estate`, or record that upstream defaults are accepted.
  - **[proposed]** replace `si-checkmarx` with a neutral local icon: the _Audit_ tile is not a
    Checkmarx product, and the icon is hotlinked from a third-party CDN.
  - **[proposed]** set `language: fr` in the settings template, or write the labels in English.
- **Known gaps:** no script maps `estate.values.yaml` to the environment `render.sh` reads, and
  several variables it expects (`PORTAL_LDAP_GROUP`, `FLEET_*`) have no key of that name there; `portalInstances`
  and `groupsShown` are read by no template; the _Audit_ group is missing from `layout`.
- **Maintenance:** owner of this fork. Update this file with any change under `deploy/estate`;
  upstream UI changes arrive by rebase and are not documented here.
