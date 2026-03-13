# Ruby Selenium SmartUI Hooks Sample

Visual regression testing with LambdaTest SmartUI using the **Hooks flow** (WebHook) in Ruby Selenium, automated via GitHub Actions.

## How It Works

This sample uses the **SmartUI Hooks (WebHook) approach**:
- Tests run on **LambdaTest cloud infrastructure** (remote Selenium grid)
- Screenshots are captured via JavaScript commands executed in the browser:
  - `driver.execute_script("smartui.takeScreenshot=<name>")` — viewport screenshot
  - `driver.execute_script("smartui.takeFullPageScreenshot=<name>")` — full page screenshot
- SmartUI capabilities are passed via `LT:Options` in the test (`smartUI.project`, `smartUI.build`)
- **No SmartUI CLI or `PROJECT_TOKEN` needed** — authentication uses `LT_USERNAME` + `LT_ACCESS_KEY`
- Project type: `web`

## Prerequisites

- Ruby (>= 2.7)
- Bundler
- A LambdaTest account with SmartUI enabled

## Local Setup

```bash
# Clone the repo
git clone <this-repo-url>
cd ruby-selenium-smartui-hooks-sample

# Install dependencies
gem install bundler && bundle install

# Set credentials
export LT_USERNAME='your-username'
export LT_ACCESS_KEY='your-access-key'

# Run the test
bundle exec ruby todo-click-test.rb
```

## GitHub Actions Setup

The workflow at `.github/workflows/smartui-hooks.yml` runs automatically on pushes/PRs to `main`, or manually via `workflow_dispatch`.

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `LT_USERNAME` | Your LambdaTest username |
| `LT_ACCESS_KEY` | Your LambdaTest access key |

Add these in your repo: **Settings > Secrets and variables > Actions > New repository secret**

### What the Workflow Does

1. Checks out the repo
2. Sets up Ruby 3.2 with bundler caching
3. Installs gem dependencies
4. Runs `todo-click-test.rb` which:
   - Connects to LambdaTest remote grid (`hub.lambdatest.com`)
   - Opens the sample todo app
   - Takes 4 SmartUI screenshots at different states:
     - `todo-app-initial` — page load
     - `todo-app-items-clicked` — after clicking list items
     - `todo-app-item-added` — after adding a new item
     - `todo-app-full-page` — full page screenshot
   - Reports pass/fail status back to LambdaTest

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `BUILD_NAME` | `Ruby SmartUI Hooks Build` | SmartUI build name (auto-set in CI) |
| `SMARTUI_PROJECT` | `ruby-smartui-hooks-project` | SmartUI project name |

## SmartUI Dashboard

After the test runs, view results at: https://smartui.lambdatest.com/

## Hooks vs CLI SDK

| Aspect | Hooks (this sample) | CLI SDK |
|---|---|---|
| **Where tests run** | LambdaTest cloud grid | Local or cloud |
| **Screenshot method** | `driver.execute_script("smartui.takeScreenshot=<name>")` | `smartui_snapshot(driver, "name")` via SDK gem |
| **Auth** | `LT_USERNAME` + `LT_ACCESS_KEY` | `PROJECT_TOKEN` |
| **CLI required** | No | Yes (`npx smartui exec -- <command>`) |
| **Project type** | `web` | `cli` |
| **Rendering** | Cloud browser captures pixels directly | CLI captures DOM, SmartUI cloud renders |
