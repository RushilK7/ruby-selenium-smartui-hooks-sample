# =============================================================================
# SmartUI Hooks (WebHook) — Ruby Selenium Sample
# =============================================================================
#
# This test demonstrates visual regression testing using LambdaTest SmartUI
# with the Hooks (WebHook) approach. Tests run on the LambdaTest cloud
# Selenium grid and capture screenshots using JavaScript hooks.
#
# Screenshot hooks:
#   driver.execute_script("smartui.takeScreenshot=<name>")
#   driver.execute_script("smartui.takeFullPageScreenshot=<name>")
#
# Prerequisites:
#   export LT_USERNAME='your-username'
#   export LT_ACCESS_KEY='your-access-key'
#
# Run:
#   bundle exec ruby todo-click-test.rb
#
# =============================================================================

require 'rubygems'
require 'selenium-webdriver'

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

USERNAME   = ENV["LT_USERNAME"]  || "{username}"
ACCESS_KEY = ENV["LT_ACCESS_KEY"] || "{accessToken}"

# Browser and platform capabilities
options = Selenium::WebDriver::Options.chrome
options.browser_version = "latest"
options.platform_name   = "Windows 10"

# LambdaTest session capabilities
lt_options = {
  username:    USERNAME,
  accessKey:   ACCESS_KEY,
  project:     "SmartUI Hooks Sample",
  sessionName: "Ruby Selenium - SmartUI Hooks",
  build:       ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build",
  w3c:         true,
  plugin:      "ruby-ruby"
}

# SmartUI capabilities (Hooks / WebHook flow)
# - smartUI.project : name of the SmartUI project on the dashboard
# - smartUI.build   : build name for grouping screenshots
# - smartUI.baseline: set to true to mark this build as the project baseline
lt_options["smartUI.project"]  = ENV["SMARTUI_PROJECT"] || "ruby-smartui-hooks"
lt_options["smartUI.build"]    = ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build"
lt_options["smartUI.baseline"] = false

options.add_option('LT:Options', lt_options)

# ---------------------------------------------------------------------------
# Connect to the LambdaTest Selenium grid
# ---------------------------------------------------------------------------

driver = Selenium::WebDriver.for(:remote,
  url:          "https://hub.lambdatest.com/wd/hub",
  capabilities: options)

begin
  # -------------------------------------------------------------------------
  # Step 1: Open the sample todo app
  # -------------------------------------------------------------------------
  driver.navigate.to "https://lambdatest.github.io/sample-todo-app/"

  # Capture the initial page state
  driver.execute_script("smartui.takeScreenshot=todo-app-initial")

  # -------------------------------------------------------------------------
  # Step 2: Interact with the app — click the first two list items
  # -------------------------------------------------------------------------
  driver.find_element(:name, 'li1').click
  driver.find_element(:name, 'li2').click

  # Capture after clicking items (checkboxes should be checked)
  driver.execute_script("smartui.takeScreenshot=todo-app-items-clicked")

  # -------------------------------------------------------------------------
  # Step 3: Add a new todo item
  # -------------------------------------------------------------------------
  driver.find_element(:id, 'sampletodotext').send_keys("Yey, Let's add it to list")
  driver.find_element(:id, 'addbutton').click

  # Verify the new item was added
  entered_text = driver.find_element(:xpath, '/html/body/div/div/div/ul/li[6]/span').text

  # Capture after adding the new item
  driver.execute_script("smartui.takeScreenshot=todo-app-item-added")

  # Capture a full-page screenshot
  driver.execute_script("smartui.takeFullPageScreenshot=todo-app-full-page")

  # -------------------------------------------------------------------------
  # Step 4: Report test status back to LambdaTest
  # -------------------------------------------------------------------------
  status = (entered_text == "Yey, Let's add it to list") ? "passed" : "failed"
  driver.execute_script("lambda-status=#{status}")

rescue => e
  driver.execute_script("lambda-status=failed") rescue nil
  raise e

ensure
  driver.quit
end

puts "Test completed successfully."
