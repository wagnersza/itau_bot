Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { js_errors: false, timeout: 10000, phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=any'] })
end

Capybara.current_driver = :poltergeist
Capybara.run_server = false
Capybara.app_host = "https://www.itau.com.br"
# Capybara.ignore_hidden_elements = false
