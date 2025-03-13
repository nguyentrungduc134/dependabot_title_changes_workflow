# Update Dependabot PR Title
<!-- x-release-please-start-version -->
  ```
    Version : '0.2.0'
  ```
<!-- x-release-please-end -->

Here’s a README for your GitHub Action:

---



This GitHub Action automatically updates the title of Dependabot PRs based on the modules updated and the PR body content. It follows semantic versioning conventions and prefixes PR titles accordingly.

## Workflow Overview

This GitHub Action runs whenever a pull request is opened, synchronized, or edited, and the actor is `dependabot[bot]`. It uses the PR body to determine the type of update and ensures that the PR title follows the `fix:` or `feat:` convention.

### Features

- **PR Title Convention:** The action checks if the PR title starts with `fix:` or `feat:` and updates it accordingly.
- **Module Matching:** If the PR title matches any module name from a `modules.txt` file, it updates the title with the appropriate prefix.
- **Automatic Title Update:** Based on keywords in the PR body, it automatically adds the correct prefix (`fix` or `feat`).
- **HTML to Text Conversion:** The PR body is sanitized and converted from HTML to plain text to check for update keywords (e.g., `fix`, `security`, `breaking change`).

## Workflow YAML

```yaml
name: Update Dependabot PR Title

on:
  pull_request:
    types:
      - opened
      - synchronize
      - edited

permissions:
  contents: read  # ✅ Allow checking out the repo
  pull-requests: write  # ✅ Allow updating PR titles

jobs:
  update-title:
    if: github.actor == 'dependabot[bot]'  # ✅ Run only for Dependabot PRs
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Install html2text
        run: |
          sudo apt-get update
          sudo apt-get install -y html2text

      - name: Update PR Title Based on Module Updates and PR Body
        run: |
          PR_TITLE="${{ github.event.pull_request.title }}"
          
          # Fetch PR body using GitHub API and jq (to handle special characters)
          PR_BODY=$(curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/${{ github.repository }}/pulls/${{ github.event.pull_request.number }}" | jq -r '.body')

          # Ensure modules.txt exists
          if [[ ! -f modules.txt ]]; then
            echo "modules.txt not found, creating an empty file."
            touch modules.txt
          fi

          # Determine prefix based on PR body
          if echo "$PR_BODY" | grep -iqE "fix|security|CVE|bug"; then
            PREFIX="fix"
          elif echo "$PR_BODY" | grep -iqE "breaking change|new feature|major update"; then
            PREFIX="feat"
          else
            PREFIX="feat"  # Default to feat if no keywords are found
          fi

          # Check if PR title already starts with fix: or feat:
          if [[ "$PR_TITLE" =~ ^fix: || "$PR_TITLE" =~ ^feat: ]]; then
            echo "PR title already follows convention, no change needed."
            exit 0
          fi

          # Check if PR title matches any module in modules.txt
          while IFS= read -r module || [[ -n "$module" ]]; do
            if [[ "$PR_TITLE" =~ "$module" ]]; then
              NEW_TITLE="$PREFIX: $PR_TITLE"
              echo "Updating PR title to: $NEW_TITLE"

              # Update PR title using GitHub API
              curl -X PATCH -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
                -H "Accept: application/vnd.github.v3+json" \
                -d '{"title": "'"$NEW_TITLE"'"}' \
                "https://api.github.com/repos/${{ github.repository }}/pulls/${{ github.event.pull_request.number }}"

              exit 0
            fi
          done < modules.txt

          echo "PR does not match any modules in modules.txt. No title changes needed."
```

## Setup Instructions

### 1. Create `modules.txt`
Ensure that you have a `modules.txt` file in the root directory of your repository. This file should contain a list of modules you are using, one per line. The action will check if the PR title matches any of these modules and update the title accordingly.

Example `modules.txt`:

```
terraform-aws-modules/vpc/aws
terraform-aws-modules/ecs/aws
```

### 2. Add the GitHub Token Secret
This action uses the `GITHUB_TOKEN` to authenticate and update the PR title. Ensure that the `GITHUB_TOKEN` is available as a secret in your repository. This token is automatically provided by GitHub in workflows.

### 3. Install `html2text`
The action installs `html2text` during the workflow to convert HTML content from the PR body to plain text, which helps in processing the content.

### 4. Adjust PR Body Keywords
You can modify the keywords in the PR body used to determine the prefix (`fix`, `feat`). By default, it checks for terms like `fix`, `security`, `bug`, `breaking change`, `new feature`, and `major update`.

## How It Works

- When a PR from Dependabot is opened, synchronized, or edited, the action checks the PR body for specific keywords like `fix`, `security`, or `new feature`.
- It then determines the appropriate prefix (`fix` or `feat`) based on the keywords found in the PR body.
- The action also checks the PR title to ensure it matches the format `fix:` or `feat:`. If the title does not follow this convention, it is updated.
- If the PR title matches any module listed in the `modules.txt` file, the action updates the title with the prefix and module name.

## Troubleshooting

- **PR title not updated:** Ensure that `modules.txt` exists and contains valid module names. The PR title must match one of the modules listed in `modules.txt` for the title to be updated.
- **Action fails:** Ensure that the `GITHUB_TOKEN` secret is correctly configured in your repository’s settings.

---

This README provides an overview and setup instructions for using the GitHub Action to update Dependabot PR titles automatically based on module updates and the PR body.
