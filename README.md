# 🧩 GitHub Workflow Generator

This script automatically generates GitHub Actions workflow files for multiple branches and market combinations.  
It’s designed to simplify the process of creating **Shopify Multi-Store Deployer** workflows across environments and markets.

---

## 📜 Overview

The script takes a **store name**, a list of **branches**, and a list of **markets**, then generates workflow YAML files inside `.github/workflows/`.  
Each generated workflow automatically handles deployment from a given branch to a corresponding `stores/<branch>-<store>-<market>` branch.

This helps automate multi-store syncs between Shopify environments (e.g. *develop*, *feature*, *staging*) and regional stores (*US*, *EU*, etc.).

---

## ⚙️ Usage

```bash
./generate-workflow.sh "Store Name" "branch1,branch2,..." "market1,market2,..."
```

## ⚙️ Example

```bash
./generate-workflow.sh "Turtle" "develop,feature" "uk,us,eu"
```

This will generate workflow files for:
| Branch  | Market | Output Filename                              |
| ------- | ------ | -------------------------------------------- |
| develop | US     | `.github/workflows/develop-turtle-us.yml` |
| develop | EU     | `.github/workflows/develop-turtle-eu.yml` |
| develop | all    | `.github/workflows/develop-turtle-uk.yml`    |
| feature | US     | `.github/workflows/feature-turtle-us.yml` |
| feature | EU     | `.github/workflows/feature-turtle-eu.yml` |
| feature | all    | `.github/workflows/feature-turtle-uk.yml`    |
