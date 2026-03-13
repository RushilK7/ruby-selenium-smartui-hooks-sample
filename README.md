# SmartUI Hooks — Ruby Selenium Sample

Visual regression testing with [LambdaTest SmartUI](https://smartui.lambdatest.com/) using the **Hooks (WebHook)** approach in Ruby Selenium, with GitHub Actions CI integration.

---

## Table of Contents

- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Quick Start (Local)](#quick-start-local)
- [Project Structure](#project-structure)
- [Test Files](#test-files)
- [GitHub Actions Integration](#github-actions-integration)
- [Testing Visual Diffs](#testing-visual-diffs)
- [SmartUI Screenshot Hooks Reference](#smartui-screenshot-hooks-reference)
- [Configuration Reference](#configuration-reference)
- [SmartUI Dashboard](#smartui-dashboard)
- [Troubleshooting](#troubleshooting)

---

## How It Works

This sample uses the **SmartUI Hooks (WebHook)** approach:

1. Tests run on the **LambdaTest cloud Selenium grid** (`hub.lambdatest.com`)
2. Screenshots are captured using JavaScript hooks executed in the browser
3. SmartUI compares screenshots against a baseline to detect visual regressions
4. No SmartUI CLI or `PROJECT_TOKEN` is required — authentication uses `LT_USERNAME` + `LT_ACCESS_KEY`

```
Your Test Code
    |
    v
LambdaTest Cloud Grid (runs browser)
    |
    |-- driver.execute_script("smartui.takeScreenshot=<name>")
    |
    v
SmartUI Dashboard (compares against baseline)
```

---

## Prerequisites

- **Ruby** >= 3.0
- **Bundler** gem
- A [LambdaTest account](https://accounts.lambdatest.com/register) with SmartUI access
- Your LambdaTest credentials (`Settings > Account Settings > Password & Security`)

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
│   └── smartui-hooks.yml           # GitHub Actions workflow
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

3. **Create a pull request** — the workflow runs automatically on PRs to `main`

4. **Manual dispatch** — go to **Actions > SmartUI Hooks - Ruby Selenium > Run workflow** and select which test file to run

### Workflow File

The workflow is at `.github/workflows/smartui-hooks.yml`:

- **Triggers**: Pull requests to `main`, manual dispatch
- **Runner**: `ubuntu-latest` with Ruby 3.2
- **Test file**: configurable via manual dispatch dropdown (defaults to `todo-click-test.rb`)

### Manual Dispatch Options

When triggering manually, you can choose which test file to run:

| Option | Description |
|---|---|
| `todo-click-test.rb` | Baseline — captures the default UI |
| `todo-click-test-modified.rb` | Modified — dark theme to trigger visual diffs |

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
lt_options["smartUI.project"]  = "your-project-name"   # SmartUI project name
lt_options["smartUI.build"]    = "your-build-name"      # Build name for grouping
lt_options["smartUI.baseline"] = true                   # Set true to mark as baseline
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

### Baseline Management

For Hooks (WebHook / `web` project type), baselines are managed via:

- **`smartUI.baseline: true`** capability — marks the build as baseline at creation time
- **SmartUI Dashboard** — approve/reject screenshots and manage baselines manually
- **Auto-Approval Branches** — configure in project settings to auto-approve builds from specific branches

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
| `bundle install` fails | Ensure Ruby >= 3.0 is installed (`ruby --version`) |
| GitHub Actions fails | Check that secrets `LT_USERNAME` and `LT_ACCESS_KEY` are configured in the repository settings |

---

## Links

- [LambdaTest SmartUI Documentation](https://www.lambdatest.com/support/docs/smartui-selenium-js-sdk/)
- [SmartUI Dashboard](https://smartui.lambdatest.com/)
- [LambdaTest Selenium Ruby Documentation](https://www.lambdatest.com/support/docs/ruby-with-selenium-running-ruby-automation-scripts-on-lambdatest-selenium-grid/)
- [LambdaTest Capabilities Generator](https://www.lambdatest.com/capabilities-generator/)
