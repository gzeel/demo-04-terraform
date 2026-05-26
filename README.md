# Demo 4: Terraform CI/CD Pipeline

**Doel:** Studenten laten zien hoe een Terraform-pipeline werkt — met `fmt`, `validate`, `tflint` (best practices), `plan`, `apply` (alleen op main), en handmatige `destroy`.

## Concept
- Terraform-manifest dat een **nginx Docker-container** start (geen cloud-account nodig!).
- Pipeline met 5 stages die alleen draaien bij wijzigingen in `terraform/`:
  1. **fmt** — `terraform fmt -check` (code-stijl)
  2. **validate** — `terraform validate` (syntax & config)
  3. **tflint** — controleert best practices (naming, deprecated syntax, etc.)
  4. **plan** — `terraform plan` (laat zien wat er zou veranderen)
  5. **apply** — voert echt uit, **alleen op push naar main**
- Aparte **handmatig te starten** `destroy`-workflow die alle infrastructuur opruimt.

## Stappenplan demo

### 1. Repository aanmaken
```bash
git clone git@github.com:<jouw-username>/terraform-cicd-demo.git
cd terraform-cicd-demo
cp -r /pad/naar/demo-04-terraform-pipeline/* .
git add .
git commit -m "Start: Terraform Docker pipeline"
git push -u origin main
```

### 2. Pipeline zien lopen op main
- Ga naar **Actions** → je ziet alle 5 stages (fmt → validate → tflint → plan → apply).
- Als Docker werkt op de GitHub-runner, zie je `apply` slagen.

### 3. Path-filter demo: README wijzigen
```bash
# Pas de README aan (bijv. voeg een regel toe)
echo "## Extra regel" >> README.md
git add README.md
git commit -m "docs: update README"
git push
```
- Ga naar **Actions** → **geen** Terraform-workflow gestart!
- De `paths:`-filter voorkomt dat niet-Terraform-wijzigingen de pipeline triggeren.

### 4. Path-filter demo: Terraform wijzigen
```bash
# Wijzig iets in main.tf (bijv. poort 8080 → 9090)
# pas het bestand aan en:
git add terraform/main.tf
git commit -m "feat: wijzig nginx poort naar 9090"
git push
```
- Nu draait de pipeline **wel** — alleen voor Terraform-wijzigingen.

### 5. Pull Request demo
```bash
git checkout -b feature/tf-patch
# Wijzig het label in main.tf
git add terraform/main.tf
git commit -m "feat: update label"
git push -u origin feature/tf-patch
```
- Open een PR op GitHub.
- De pipeline draait fmt → validate → tflint → plan, maar **géén apply**.
- Merge de PR → op main draait ook apply.

### 6. Handmatige destroy demo
- Ga naar **Actions** → klik **"Terraform — Destroy (Handmatig)"**.
- Klik **"Run workflow"**.
- Vul bij `confirm` in: `DESTROY`.
- De workflow stopt en verwijdert de Docker-container.

## Wat leg je uit
| Mechanisme | Waar | Effect |
|-----------|------|--------|
| `paths: ['terraform/**']` | Workflow trigger | Pipeline draait alleen bij Terraform-wijzigingen |
| `terraform fmt -check` | Stage `fmt` | Faalt als code niet netjes geformatteerd is |
| `terraform validate` | Stage `validate` | Controleert of de configuratie geldig is |
| `tflint` | Stage `tflint` | Controleert best practices (bv. naming conventions) |
| `needs:` | Elke stage | Sequential execution; faalt vroeg als iets mis is |
| `if: github.event_name == 'push' && github.ref == 'refs/heads/main'` | Job `apply` | Apply alleen op main; feature branches krijgen alleen plan |
| `workflow_dispatch` | Destroy workflow | Alleen handmatig te starten (veiligheid!) |
| `inputs.confirm` | Destroy workflow | Extra bevestiging vóór destroy |

## Benodigdheden
- GitHub account
- Git lokaal geïnstalleerd
- Docker (voor lokale tests)
- Terraform lokaal (optioneel — om lokaal te testen)

> **Opmerking:** Op GitHub's shared runners is Docker beschikbaar, maar met beperkte rechten. Voor een live-demo is het aan te raden een **self-hosted runner** te gebruiken (zie Demo 2) of het manifest naar je lokale machine te kopiëren en daar `terraform apply` te draaien.
