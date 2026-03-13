# SmartUI Hooks — Ruby Selenium Sample

Visual regression testing with [LambdaTest SmartUI](https://smartui.lambdatest.com/) using the **Hooks** approach in Ruby Selenium, with GitHub Actions CI and **PR status checks**.

---

## Prerequisites

- **Ruby** >= 3.0
- **Bundler** gem
- A [LambdaTest account](https://accounts.lambdatest.com/register) with SmartUI access
- Your LambdaTest credentials (`Settings > Account Settings > Password & Security`)

---

## Step 1: Clone and Install

```bash
git clone https://github.com/LambdaTest/ruby-selenium-smartui-hooks-sample.git
cd ruby-selenium-smartui-hooks-sample
gem install bundler && bundle install
```

---

## Step 2: Set Your Credentials

```bash
export LT_USERNAME='your-lambdatest-username'
export LT_ACCESS_KEY='your-lambdatest-access-key'
```

---

## Step 3: Run the Baseline Test

```bash
bundle exec ruby todo-click-test.rb
```

This captures 4 screenshots of the sample todo app:

| Screenshot | What it captures |
|---|---|
| `todo-app-initial` | Page after initial load |
| `todo-app-items-clicked` | After clicking the first two list items |
| `todo-app-item-added` | After adding a new todo item |
| `todo-app-full-page` | Full-page screenshot of the final state |

---

## Step 4: Approve the Baseline

1. Open the [SmartUI Dashboard](https://smartui.lambdatest.com/)
2. Find your project and open the build
3. **Approve** the screenshots to set them as the baseline

---

## Step 5: Run the Modified Test (Visual Diffs)

```bash
bundle exec ruby todo-click-test-modified.rb
```

This runs the same test flow but injects a dark theme and layout changes before capturing screenshots. The SmartUI Dashboard will highlight all visual differences against your approved baseline.

---

## Setting Up GitHub Actions

### 1. Add repository secrets

Go to **Settings > Secrets and variables > Actions > New repository secret** and add:

| Secret | Value |
|---|---|
| `LT_USERNAME` | Your LambdaTest username |
| `LT_ACCESS_KEY` | Your LambdaTest access key |

### 2. Install the LambdaTest GitHub integration

This is required for PR status checks to appear on your pull requests.

1. Go to the [LambdaTest Integrations page](https://integrations.lambdatest.com/)
2. Search for **GitHub** and install it
3. Authorize access to your repository

### 3. Create a pull request

The workflow runs automatically on PRs to `main`. After the test completes, a SmartUI status check will appear on the PR showing whether visual differences were detected.

### 4. Run manually (optional)

Go to **Actions > SmartUI Hooks - Ruby Selenium > Run workflow** and select which test file to run:

| Option | Description |
|---|---|
| `todo-click-test.rb` | Baseline — captures the default UI |
| `todo-click-test-modified.rb` | Modified — dark theme to trigger visual diffs |

---

## Setting Up GitLab CI/CD

### 1. Add CI/CD variables

Go to **Settings > CI/CD > Variables** and add:

| Variable | Value |
|---|---|
| `LT_USERNAME` | Your LambdaTest username |
| `LT_ACCESS_KEY` | Your LambdaTest access key |

### 2. Install the LambdaTest GitLab integration

1. Go to the [LambdaTest Integrations page](https://integrations.lambdatest.com/)
2. Search for **GitLab** and select it
3. Click **OAuth** as the authentication method
4. Click **Install** and authorize

### 3. Add the pipeline configuration

Create a `.gitlab-ci.yml` file:

```yaml
stages:
  - test

variables:
  LT_USERNAME: $LT_USERNAME
  LT_ACCESS_KEY: $LT_ACCESS_KEY
  SMARTUI_PROJECT: "ruby-smartui-hooks"

visual_regression:
  stage: test
  image: ruby:3.2
  before_script:
    - gem install bundler && bundle install
  script:
    - |
      PROJECT_ID=${CI_PROJECT_ID}
      COMMIT_SHA=${CI_MERGE_REQUEST_SHA:-${CI_COMMIT_SHA}}
      export GIT_URL="https://gitlab.com/api/v4/projects/${PROJECT_ID}/statuses/${COMMIT_SHA}"

      bundle exec ruby todo-click-test.rb
  only:
    - merge_requests
    - main
```

After the test completes, a SmartUI status check will appear on the merge request.

---

## Testing PR Checks Locally

You can verify PR status checks work without CI by setting `GIT_URL` manually:

```bash
export LT_USERNAME='your-username'
export LT_ACCESS_KEY='your-access-key'

# For GitHub
export GIT_URL='https://api.github.com/repos/your-org/your-repo/statuses/your-commit-sha'

# For GitLab
export GIT_URL='https://gitlab.com/api/v4/projects/your-project-id/statuses/your-commit-sha'

bundle exec ruby todo-click-test.rb
```

---

## Managing Baselines

| Method | How to use |
|---|---|
| **SmartUI Dashboard** | Approve or reject screenshots manually from the build page |
| **Auto-Approval Branches** | In your project **Settings > Git Settings**, configure branches that auto-approve |
| **Smart Baseline** | Enable in project **Settings** to auto-update the baseline when screenshots are approved |
| **`smartUI.baseline: true`** | Set this capability in your test code to mark a build as baseline at creation time |

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `401 Unauthorized` | Verify `LT_USERNAME` and `LT_ACCESS_KEY` are set correctly |
| Screenshots not appearing | Ensure `smartUI.project` matches an existing project on the dashboard |
| No visual diffs shown | Run `todo-click-test.rb` first and approve it as baseline, then run `todo-click-test-modified.rb` |
| PR check not appearing | Ensure the LambdaTest GitHub/GitLab integration is installed and authorized |
| PR check stuck on pending | Wait for the SmartUI build to finish processing all screenshots |
| `bundle install` fails | Ensure Ruby >= 3.0 is installed (`ruby --version`) |
| GitHub Actions fails | Check that secrets are configured in **Settings > Secrets and variables > Actions** |

---

## Links

- [SmartUI GitHub App Integration](https://www.lambdatest.com/support/docs/smartui-github-app-integration/)
- [SmartUI GitLab MR Checks](https://www.lambdatest.com/support/docs/smartui-gitlab-pr-checks-hooks/)
- [SmartUI Documentation](https://www.lambdatest.com/support/docs/smartui-selenium-js-sdk/)
- [SmartUI Dashboard](https://smartui.lambdatest.com/)
- [LambdaTest Capabilities Generator](https://www.lambdatest.com/capabilities-generator/)
