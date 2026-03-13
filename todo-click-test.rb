require 'rubygems'
require 'selenium-webdriver'

# LambdaTest credentials
USERNAME = ENV["LT_USERNAME"] || "{username}"
ACCESS_KEY = ENV["LT_ACCESS_KEY"] || "{accessToken}"

# Chrome options and LambdaTest capabilities
options = Selenium::WebDriver::Options.chrome
options.browser_version = "latest"
options.platform_name = "Windows 10"

lt_options = {}
lt_options[:username] = "#{USERNAME}"
lt_options[:accessKey] = "#{ACCESS_KEY}"
lt_options[:project] = "Untitled"
lt_options[:sessionName] = "Ruby SmartUI Hooks Test"
lt_options[:build] = ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build"
lt_options[:w3c] = true
lt_options[:plugin] = "ruby-ruby"

# SmartUI Webhook capabilities
lt_options["smartUI.project"] = ENV["SMARTUI_PROJECT"] || "github_hooks"
lt_options["smartUI.build"] = ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build"
lt_options["smartUI.baseline"] = false

options.add_option('LT:Options', lt_options)

driver = Selenium::WebDriver.for(:remote,
  :url => "https://hub.lambdatest.com/wd/hub",
  :capabilities => options)

begin
  # Navigate to the sample todo app
  driver.navigate.to "https://lambdatest.github.io/sample-todo-app/"

  # Take SmartUI screenshot of the initial page state
  driver.execute_script("smartui.takeScreenshot=todo-app-initial")

  # Click on first two list items
  driver.find_element(:name, 'li1').click
  driver.find_element(:name, 'li2').click

  # Take SmartUI screenshot after clicking items
  driver.execute_script("smartui.takeScreenshot=todo-app-items-clicked")

  # Add a new todo item
  driver.find_element(:id, 'sampletodotext').send_keys("Yey, Let's add it to list")
  driver.find_element(:id, 'addbutton').click

  # Verify the new item was added
  entered_text = driver.find_element(:xpath, '/html/body/div/div/div/ul/li[6]/span').text

  # Take SmartUI screenshot of the final page state
  driver.execute_script("smartui.takeScreenshot=todo-app-item-added")

  # Take a full page screenshot as well
  driver.execute_script("smartui.takeFullPageScreenshot=todo-app-full-page")

  # Report test status
  status = entered_text == "Yey, Let's add it to list" ? "passed" : "failed"
  driver.execute_script('lambda-status=' + status)
end

print("Execution Successful\n")
driver.quit
