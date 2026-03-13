# SmartUI Hooks — Ruby Selenium Sample

Visual regression testing with [LambdaTest SmartUI](https://smartui.lambdatest.com/) using the **Hooks (WebHook)** approach in Ruby Selenium, with GitHub Actions CI integration and **PR status checks**.

---

## Table of Contents

- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Quick Start (Local)](#quick-start-local)
- [Project Structure](#project-structure)
- [Test Files](#test-files)
- [GitHub Actions Integration](#github-actions-integration)
- [PR Status Checks](#pr-status-checks)
- [GitLab MR Checks](#gitlab-mr-checks)
- [Testing Visual Diffs](#testing-visual-diffs)
- [SmartUI Screenshot Hooks Reference](#smartui-screenshot-hooks-reference)
- [Configuration Reference](#configuration-reference)
- [Baseline Management](#baseline-management)
- [SmartUI Dashboard](#smartui-dashboard)
- [Troubleshooting](#troubleshooting)

---

## How It Works

This sample uses the **SmartUI Hooks (WebHook)** approach:

1. Tests run on the **LambdaTest cloud Selenium grid** (`hub.lambdatest.com`)
2. Screenshots are captured using JavaScript hooks executed in the browser
3. SmartUI compares screenshots against a baseline to detect visual regressions
4. Build results are posted as a **status check on your PR** (GitHub or GitLab)
5. No SmartUI CLI or `PROJECT_TOKEN` is required — authentication uses `LT_USERNAME` + `LT_ACCESS_KEY`

```
Your Test Code
    |
    v
LambdaTest Cloud Grid (runs browser)
    |
    |-- driver.execute_script("smartui.takeScreenshot=<name>")
    |-- github.url capability (for PR status checks)
    |
    v
SmartUI Dashboard              GitHub / GitLab PR
(compares against baseline) --> (posts status check)
```

---

## Prerequisites

- **Ruby** >= 3.0
- **Bundler** gem
- A [LambdaTest account](https://accounts.lambdatest.com/register) with SmartUI access
- Your LambdaTest credentials (`Settings > Account Settings > Password & Security`)

### For PR Status Checks (Optional)

- **GitHub**: Install the [LambdaTest GitHub App](https://github.com/apps/lambdatest) or set up the [GitHub integration](https://www.lambdatest.com/support/docs/smartui-github-app-integration/) from the LambdaTest Integrations page
- **GitLab**: Set up the [GitLab integration](https://www.lambdatest.com/support/docs/gitlab-integration/) from the LambdaTest Integrations page (use OAuth authentication)

---

## Quick Start (Local)

### 1. Clone and install

```bash
git clone https://github.com/LambdaTest/ruby-selenium-smartui-hooks-sample.git
cd ruby-selenium-smartui-hooks-sample
gem install bundler && bundle install
```

### 2. Set your LambdaTest credentials

```bash
export LT_USERNAME='your-lambdatest-username'
export LT_ACCESS_KEY='your-lambdatest-access-key'
```

### 3. Run the baseline test

```bash
bundle exec ruby todo-click-test.rb
```

### 4. Run the modified test (to generate visual diffs)

```bash
bundle exec ruby todo-click-test-modified.rb
```

### 5. View results

Open the [SmartUI Dashboard](https://smartui.lambdatest.com/) and navigate to your project to review screenshots and visual diffs.

---

## Project Structure

```
.
├── .github/workflows/
│   └── smartui-hooks.yml           # GitHub Actions workflow (with PR checks)
├── .gitignore
├── Gemfile                         # Ruby dependencies (selenium-webdriver)
├── README.md
├── todo-click-test.rb              # Baseline test (clean UI)
└── todo-click-test-modified.rb     # Modified test (dark theme — triggers visual diffs)
```

---

## Test Files

### `todo-click-test.rb` — Baseline

The baseline test captures the sample todo app in its default state:

| Screenshot Name | Description |
|---|---|
| `todo-app-initial` | Page after initial load |
| `todo-app-items-clicked` | After clicking the first two list items |
| `todo-app-item-added` | After adding a new todo item |
| `todo-app-full-page` | Full-page screenshot of the final state |

### `todo-click-test-modified.rb` — Modified (Visual Diffs)

Identical test flow but injects CSS/DOM changes before capturing screenshots:

- Dark theme (background `#1a1a2e`, accent `#e94560`)
- Monospace typography with uppercase headers
- Restyled list items, buttons, and inputs
- Added banner and footer elements

Run this after establishing a baseline to see SmartUI detect visual regressions.

---

## GitHub Actions Integration

### Setup

1. **Fork or clone** this repository

2. **Add secrets** to your GitHub repository:

   Go to **Settings > Secrets and variables > Actions > New repository secret** and add:

   | Secret | Value |
   |---|---|
   | `LT_USERNAME` | Your LambdaTest username |
   | `LT_ACCESS_KEY` | Your LambdaTest access key |

3. **Install the LambdaTest GitHub integration** (required for PR checks):
   - Go to the [LambdaTest Integrations page](https://integrations.lambdatest.com/)
   - Search for **GitHub** and install it
   - Authorize access to your repository

4. **Create a pull request** — the workflow runs automatically on PRs to `main`

5. **Manual dispatch** — go to **Actions > SmartUI Hooks - Ruby Selenium > Run workflow** and select which test file to run

### Workflow File

The workflow is at `.github/workflows/smartui-hooks.yml`:

- **Triggers**: Pull requests to `main`, manual dispatch
- **Runner**: `ubuntu-latest` with Ruby 3.2
- **Test file**: configurable via manual dispatch dropdown (defaults to `todo-click-test.rb`)
- **PR checks**: automatically constructs the GitHub Status API URL and passes it to the test

---

## PR Status Checks

When running in CI, the workflow automatically constructs a GitHub Status API URL and passes it to the test via the `GIT_URL` environment variable. SmartUI uses this to post build results as a **commit status check** on the pull request.

### How It Works

1. The workflow constructs the URL:
   ```
   https://api.github.com/repos/{owner}/{repo}/statuses/{commit_sha}
   ```

2. The test passes it as a capability:
   ```ruby
   lt_options[:github] = { url: ENV["GIT_URL"] }
   ```

3. SmartUI posts the build result as a status check on the PR:
   - **Success** — all screenshots match baseline or are approved
   - **Failure** — visual differences detected, review required

### What You See on the PR

After the test completes, a SmartUI status check appears on the pull request:

- **Status**: Success / Failure / Pending
- **Details link**: click to open the SmartUI build in the dashboard
- **Summary**: screenshot statistics (total, approved, changes found)

### Running Locally with PR Checks

You can also test PR checks locally by setting the `GIT_URL` manually:

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

## GitLab MR Checks

The same `github.url` capability (legacy name) works with GitLab. To use this with GitLab CI/CD:

### `.gitlab-ci.yml` Example

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
      # Construct the GitLab Status API URL
      PROJECT_ID=${CI_PROJECT_ID}
      COMMIT_SHA=${CI_MERGE_REQUEST_SHA:-${CI_COMMIT_SHA}}
      export GIT_URL="https://gitlab.com/api/v4/projects/${PROJECT_ID}/statuses/${COMMIT_SHA}"

      echo "GitLab Status URL: ${GIT_URL}"
      bundle exec ruby todo-click-test.rb
  only:
    - merge_requests
    - main
```

### GitLab CI/CD Variables

| Variable | Description |
|---|---|
| `LT_USERNAME` | Your LambdaTest username |
| `LT_ACCESS_KEY` | Your LambdaTest access key |

Add these in **Settings > CI/CD > Variables**.

### GitLab Integration Setup

1. Go to the [LambdaTest Integrations page](https://integrations.lambdatest.com/)
2. Search for **GitLab** and select it
3. Click **OAuth** as the authentication method
4. Click **Install** and authorize
5. Refresh the page to confirm it shows as installed

---

## Testing Visual Diffs

Follow these steps to see SmartUI detect visual regressions:

### Step 1: Establish a baseline

```bash
export LT_USERNAME='your-username'
export LT_ACCESS_KEY='your-access-key'
bundle exec ruby todo-click-test.rb
```

Go to the [SmartUI Dashboard](https://smartui.lambdatest.com/), find your project, and **approve** the build to set it as the baseline.

### Step 2: Run the modified test

```bash
bundle exec ruby todo-click-test-modified.rb
```

### Step 3: Review diffs on the dashboard

The SmartUI Dashboard will show visual diffs between the baseline and the modified screenshots, highlighting all the CSS/DOM changes.

---

## SmartUI Screenshot Hooks Reference

Use these JavaScript hooks inside `driver.execute_script()` to capture screenshots:

```ruby
# Capture a viewport screenshot
driver.execute_script("smartui.takeScreenshot=<screenshot-name>")

# Capture a full-page screenshot
driver.execute_script("smartui.takeFullPageScreenshot=<screenshot-name>")
```

### SmartUI Capabilities

Set these in `LT:Options` to configure the SmartUI project:

```ruby
# Required SmartUI capabilities
lt_options["smartUI.project"]  = "your-project-name"   # SmartUI project name
lt_options["smartUI.build"]    = "your-build-name"      # Build name for grouping
lt_options["smartUI.baseline"] = true                   # Set true to mark as baseline

# PR checks capability (GitHub or GitLab)
lt_options[:github] = { url: "https://api.github.com/repos/owner/repo/statuses/sha" }
```

---

## Configuration Reference

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `LT_USERNAME` | — | **(Required)** LambdaTest username |
| `LT_ACCESS_KEY` | — | **(Required)** LambdaTest access key |
| `BUILD_NAME` | `Ruby SmartUI Hooks Build` | SmartUI build name |
| `SMARTUI_PROJECT` | `ruby-smartui-hooks` | SmartUI project name |
| `GIT_URL` | — | GitHub/GitLab Status API URL for PR checks |

---

## Baseline Management

For Hooks (WebHook / `web` project type), baselines are managed via:

| Method | Description |
|---|---|
| `smartUI.baseline: true` | Marks the build as baseline at creation time |
| **SmartUI Dashboard** | Approve/reject screenshots and manage baselines manually |
| **Auto-Approval Branches** | Configure in project settings to auto-approve builds from specific branches |
| **Smart Baseline** | Enable in project settings to auto-update baseline for approved screenshots |

To configure auto-approval:
1. Go to the [SmartUI Dashboard](https://smartui.lambdatest.com/)
2. Open your project → **Settings**
3. Under **Git Settings**, configure **Auto-Approval Branches**
4. Enable **Smart Baseline** if desired

---

## SmartUI Dashboard

After running tests, view and manage results at:

**https://smartui.lambdatest.com/**

From the dashboard you can:
- Compare screenshots against the baseline
- Approve or reject changes
- Configure comparison settings (pixel threshold, smart ignore, etc.)
- Set up auto-approval branches
- View build history and trends

---

## Troubleshooting

| Issue | Solution |
|---|---|
| `401 Unauthorized` | Verify `LT_USERNAME` and `LT_ACCESS_KEY` are set correctly |
| Screenshots not appearing | Ensure `smartUI.project` matches an existing project on the dashboard, or a new project will be created |
| No visual diffs shown | Run `todo-click-test.rb` first and approve it as baseline, then run `todo-click-test-modified.rb` |
| PR check not appearing | Ensure the LambdaTest GitHub/GitLab integration is installed and `GIT_URL` is set correctly |
| PR check shows pending | The status is posted when the SmartUI build completes — wait for all screenshots to be processed |
| `bundle install` fails | Ensure Ruby >= 3.0 is installed (`ruby --version`) |
| GitHub Actions fails | Check that secrets `LT_USERNAME` and `LT_ACCESS_KEY` are configured in the repository settings |

---

## Links

- [SmartUI GitHub PR Checks (Hooks)](https://www.lambdatest.com/support/docs/smartui-github-app-integration/)
- [SmartUI GitLab MR Checks (Hooks)](https://www.lambdatest.com/support/docs/smartui-gitlab-pr-checks-hooks/)
- [LambdaTest SmartUI Documentation](https://www.lambdatest.com/support/docs/smartui-selenium-js-sdk/)
- [SmartUI Dashboard](https://smartui.lambdatest.com/)
- [LambdaTest Capabilities Generator](https://www.lambdatest.com/capabilities-generator/)
