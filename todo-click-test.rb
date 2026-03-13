# SmartUI Hooks — Ruby Selenium Baseline Test
#
# Captures screenshots of the sample todo app in its default state.
# Run this first to establish a baseline, then approve it on the SmartUI Dashboard.
#
# Usage:
#   export LT_USERNAME='your-username'
#   export LT_ACCESS_KEY='your-access-key'
#   bundle exec ruby todo-click-test.rb

require 'rubygems'
require 'selenium-webdriver'

# --- Credentials ---

USERNAME   = ENV["LT_USERNAME"]  || "{username}"
ACCESS_KEY = ENV["LT_ACCESS_KEY"] || "{accessToken}"

# --- Browser capabilities ---

options = Selenium::WebDriver::Options.chrome
options.browser_version = "latest"
options.platform_name   = "Windows 10"

# --- LambdaTest capabilities ---

lt_options = {
  username:    USERNAME,
  accessKey:   ACCESS_KEY,
  project:     "SmartUI Hooks Sample",
  sessionName: "Ruby Selenium - SmartUI Hooks",
  build:       ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build",
  w3c:         true,
  plugin:      "ruby-ruby"
}

# --- SmartUI capabilities ---

lt_options["smartUI.project"]  = ENV["SMARTUI_PROJECT"] || "ruby-smartui-hooks"
lt_options["smartUI.build"]    = ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build"
lt_options["smartUI.baseline"] = false

# --- PR status checks (GitHub / GitLab) ---
# Set GIT_URL to post SmartUI results as a commit status on your PR/MR.
# GitHub:  https://api.github.com/repos/{owner}/{repo}/statuses/{sha}
# GitLab:  https://gitlab.com/api/v4/projects/{project_id}/statuses/{sha}

if ENV["GIT_URL"] && !ENV["GIT_URL"].empty?
  lt_options[:github] = { url: ENV["GIT_URL"] }
  puts "PR checks enabled: #{ENV["GIT_URL"]}"
end

options.add_option('LT:Options', lt_options)

# --- Run test ---

driver = Selenium::WebDriver.for(:remote,
  url:          "https://hub.lambdatest.com/wd/hub",
  capabilities: options)

begin
  driver.navigate.to "https://lambdatest.github.io/sample-todo-app/"

  # Screenshot: initial page
  driver.execute_script("smartui.takeScreenshot=todo-app-initial")

  # Click the first two list items
  driver.find_element(:name, 'li1').click
  driver.find_element(:name, 'li2').click

  # Screenshot: after clicking items
  driver.execute_script("smartui.takeScreenshot=todo-app-items-clicked")

  # Add a new todo item
  driver.find_element(:id, 'sampletodotext').send_keys("Yey, Let's add it to list")
  driver.find_element(:id, 'addbutton').click

  entered_text = driver.find_element(:xpath, '/html/body/div/div/div/ul/li[6]/span').text

  # Screenshot: after adding item
  driver.execute_script("smartui.takeScreenshot=todo-app-item-added")

  # Screenshot: full page
  driver.execute_script("smartui.takeFullPageScreenshot=todo-app-full-page")

  # Report status
  status = (entered_text == "Yey, Let's add it to list") ? "passed" : "failed"
  driver.execute_script("lambda-status=#{status}")

rescue => e
  driver.execute_script("lambda-status=failed") rescue nil
  raise e

ensure
  driver.quit
end

puts "Test completed successfully."
