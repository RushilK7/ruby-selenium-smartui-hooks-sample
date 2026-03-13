# SmartUI Hooks — Ruby Selenium Modified Test
#
# Same test as todo-click-test.rb but injects a dark theme and layout changes
# before capturing screenshots. Run this after approving a baseline to see
# SmartUI detect visual diffs.
#
# Usage:
#   export LT_USERNAME='your-username'
#   export LT_ACCESS_KEY='your-access-key'
#   bundle exec ruby todo-click-test-modified.rb

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
  sessionName: "Ruby Selenium - SmartUI Hooks (Modified)",
  build:       ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build",
  w3c:         true,
  plugin:      "ruby-ruby"
}

# --- SmartUI capabilities (same project as baseline for comparison) ---

lt_options["smartUI.project"]  = ENV["SMARTUI_PROJECT"] || "ruby-smartui-hooks"
lt_options["smartUI.build"]    = ENV["BUILD_NAME"] || "Ruby SmartUI Hooks Build - Modified"
lt_options["smartUI.baseline"] = false

# --- PR status checks (GitHub / GitLab) ---

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

  # Inject dark theme CSS
  driver.execute_script(<<~JS)
    var style = document.createElement('style');
    style.innerHTML = `
      body {
        background-color: #1a1a2e !important;
        color: #e0e0e0 !important;
        font-family: 'Courier New', monospace !important;
      }
      .containerbox, .container, .main-content, [class*="container"] {
        background-color: #16213e !important;
        border: 3px solid #e94560 !important;
        border-radius: 20px !important;
        padding: 40px !important;
        max-width: 800px !important;
        margin: 50px auto !important;
        box-shadow: 0 0 30px rgba(233, 69, 96, 0.3) !important;
      }
      h1, h2, h3, [class*="heading"], [class*="title"], [class*="header"] {
        color: #e94560 !important;
        font-size: 36px !important;
        text-transform: uppercase !important;
        letter-spacing: 4px !important;
        text-align: left !important;
        border-bottom: 2px solid #e94560 !important;
        padding-bottom: 15px !important;
      }
      li {
        background-color: #0f3460 !important;
        color: #e0e0e0 !important;
        margin: 12px 0 !important;
        padding: 18px 20px !important;
        border-radius: 12px !important;
        font-size: 20px !important;
        border-left: 5px solid #e94560 !important;
        list-style: none !important;
      }
      li span { color: #e0e0e0 !important; }
      input[type="checkbox"] {
        width: 24px !important;
        height: 24px !important;
        margin-right: 15px !important;
        accent-color: #e94560 !important;
      }
      .done span, .completed span {
        color: #666 !important;
        text-decoration: line-through !important;
      }
      #sampletodotext, input[type="text"] {
        background-color: #0f3460 !important;
        color: #e0e0e0 !important;
        border: 2px solid #e94560 !important;
        border-radius: 10px !important;
        padding: 14px 20px !important;
        font-size: 18px !important;
        width: 70% !important;
        font-family: 'Courier New', monospace !important;
      }
      #addbutton, button, input[type="submit"] {
        background-color: #e94560 !important;
        color: white !important;
        border: none !important;
        border-radius: 10px !important;
        padding: 14px 30px !important;
        font-size: 18px !important;
        font-weight: bold !important;
        text-transform: uppercase !important;
        letter-spacing: 2px !important;
        margin-left: 10px !important;
      }
      img, .logo { filter: invert(1) hue-rotate(180deg) !important; }
      a { color: #e94560 !important; }
      div { background-color: transparent !important; }
    `;
    document.head.appendChild(style);
  JS

  # Add a banner at the top
  driver.execute_script(<<~JS)
    var banner = document.createElement('div');
    banner.style.cssText = 'background: linear-gradient(90deg, #e94560, #0f3460); color: white; text-align: center; padding: 15px; font-size: 14px; font-family: Courier New, monospace; letter-spacing: 2px;';
    banner.innerText = 'VISUAL REGRESSION TEST — DARK THEME v2.0';
    document.body.insertBefore(banner, document.body.firstChild);
  JS

  # Screenshot: initial page (with dark theme applied)
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

  # Add a footer
  driver.execute_script(<<~JS)
    var footer = document.createElement('div');
    footer.style.cssText = 'background-color: #16213e; color: #e94560; text-align: center; padding: 20px; margin-top: 30px; border-top: 2px solid #e94560; font-family: Courier New, monospace;';
    footer.innerHTML = '<strong>SmartUI Hooks</strong> | Dark Theme | New Typography';
    var target = document.querySelector('.containerbox') || document.querySelector('.container') || document.querySelector('[class*="container"]') || document.body;
    target.appendChild(footer);
  JS

  # Screenshot: after adding item + footer
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

puts "Test completed successfully (modified version)."
