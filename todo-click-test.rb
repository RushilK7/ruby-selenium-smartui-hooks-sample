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
lt_options["smartUI.baseline"] = ENV["SMARTUI_BASELINE"] == "true"

options.add_option('LT:Options', lt_options)

driver = Selenium::WebDriver.for(:remote,
  :url => "https://hub.lambdatest.com/wd/hub",
  :capabilities => options)

begin
  # Navigate to the sample todo app
  driver.navigate.to "https://lambdatest.github.io/sample-todo-app/"

  # --- MAJOR LAYOUT & STYLE CHANGES ---
  # Inject CSS overrides: dark theme, new fonts, resized elements, shifted layout
  driver.execute_script(<<~JS)
    var style = document.createElement('style');
    style.innerHTML = `
      /* Dark theme background */
      body {
        background-color: #1a1a2e !important;
        color: #e0e0e0 !important;
        font-family: 'Courier New', monospace !important;
      }

      /* Restyle the main container - bigger padding, border, rounded corners */
      .containerbox, .container, .main-content, [class*="container"] {
        background-color: #16213e !important;
        border: 3px solid #e94560 !important;
        border-radius: 20px !important;
        padding: 40px !important;
        max-width: 800px !important;
        margin: 50px auto !important;
        box-shadow: 0 0 30px rgba(233, 69, 96, 0.3) !important;
      }

      /* Header style changes */
      h1, h2, h3, [class*="heading"], [class*="title"], [class*="header"] {
        color: #e94560 !important;
        font-size: 36px !important;
        text-transform: uppercase !important;
        letter-spacing: 4px !important;
        text-align: left !important;
        border-bottom: 2px solid #e94560 !important;
        padding-bottom: 15px !important;
      }

      /* List items - completely different layout */
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

      /* All spans inside list items */
      li span {
        color: #e0e0e0 !important;
      }

      /* Checkbox styling */
      input[type="checkbox"] {
        width: 24px !important;
        height: 24px !important;
        margin-right: 15px !important;
        accent-color: #e94560 !important;
      }

      /* Strikethrough for checked items */
      .done span, .completed span {
        color: #666 !important;
        text-decoration: line-through !important;
      }

      /* Text input - wider, different style */
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

      /* Button - completely restyled */
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
        cursor: pointer !important;
        margin-left: 10px !important;
      }

      /* All images and logos */
      img, .logo {
        filter: invert(1) hue-rotate(180deg) !important;
      }

      /* All links */
      a {
        color: #e94560 !important;
      }

      /* All divs - force dark background */
      div {
        background-color: transparent !important;
      }
    `;
    document.head.appendChild(style);
  JS

  # Change the page heading text
  driver.execute_script(<<~JS)
    var heading = document.querySelector('h2') || document.querySelector('h1') || document.querySelector('.main-heading') || document.querySelector('.header h2');
    if (heading) { heading.innerText = 'MY DARK TODO APP'; }
    // Also change the first large text element found
    var firstHeader = document.querySelector('.container h2, .todoListBox h2, [class*=header], [class*=title]');
    if (firstHeader) { firstHeader.innerText = 'MY DARK TODO APP'; firstHeader.style.color = '#e94560'; }
  JS

  # Add a banner element at the top
  driver.execute_script(<<~JS)
    var banner = document.createElement('div');
    banner.style.cssText = 'background: linear-gradient(90deg, #e94560, #0f3460); color: white; text-align: center; padding: 15px; font-size: 14px; font-family: Courier New, monospace; letter-spacing: 2px;';
    banner.innerText = 'VISUAL REGRESSION TEST — MAJOR UI OVERHAUL v2.0';
    document.body.insertBefore(banner, document.body.firstChild);
  JS

  # Take SmartUI screenshot of the restyled initial page
  driver.execute_script("smartui.takeScreenshot=todo-app-initial")

  # Click on first two list items
  driver.find_element(:name, 'li1').click
  driver.find_element(:name, 'li2').click

  # Take SmartUI screenshot after clicking items (with new dark theme)
  driver.execute_script("smartui.takeScreenshot=todo-app-items-clicked")

  # Add a new todo item
  driver.find_element(:id, 'sampletodotext').send_keys("Yey, Let's add it to list")
  driver.find_element(:id, 'addbutton').click

  # Verify the new item was added
  entered_text = driver.find_element(:xpath, '/html/body/div/div/div/ul/li[6]/span').text

  # Add a footer element for extra layout change
  driver.execute_script(<<~JS)
    var footer = document.createElement('div');
    footer.style.cssText = 'background-color: #16213e; color: #e94560; text-align: center; padding: 20px; margin-top: 30px; border-top: 2px solid #e94560; font-family: Courier New, monospace;';
    footer.innerHTML = '<strong>SmartUI Hooks Test</strong> — Layout v2.0 | Dark Theme | New Typography';
    var target = document.querySelector('.containerbox') || document.querySelector('.container') || document.querySelector('[class*="container"]') || document.body;
    target.appendChild(footer);
  JS

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
