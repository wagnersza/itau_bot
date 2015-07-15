class ItauWebScraper
  include Capybara::DSL

  def initialize
    page.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11) AppleWebKit/601.1.37 (KHTML, like Gecko) Version/9.0 Safari/601.1.37" }
    visit "/"

    @payload = {}
    @credentials = ItauWebCredentials.from_env
  end

  def login
    puts "-----> Login"

    begin

      # puts page.driver.network_traffic.inspect
      # puts current_url
      # puts page.body

      fill_in "campo_agencia", with: @credentials.agencia
      fill_in "campo_conta", with: @credentials.conta
      sleep 3
      click_on "Acessar"

      # puts page.driver.network_traffic.inspect
      # puts current_url
      # puts page.body

      sleep 5
      puts current_url
      click_on @credentials.nome

      sleep 2

      puts "-----> Password"
      @credentials.senha.chars.each do |char|
        find(".TextoTecladoVar img[title*='#{char}']").click
      end

      find("img[alt='Continuar']").click

    rescue => exception
      puts exception
      raise exception # always reraise
    end
    # fill_in "campo_conta", with: @credentials.conta
    # click_on "Acessar"
    #
    # click_on @credentials.nome
    #
    # puts "-----> Password"
    # @credentials.senha.chars.each do |char|
    #   find(".TextoTecladoVar img[title*='#{char}']").click
    # end
    #
    # find("img[alt='Continuar']").click

    @logged_in = true
  end

  def scrape_balance
    login unless @logged_in
    puts "-----> Balance"

    puts "balance antes"
    puts page.driver.network_traffic.inspect

    click_on "ver extrato"
    select "ltimos 90 dias", from: "periodoExtrato"

    puts current_url

    puts "balance depois"
    puts page.driver.network_traffic.inspect


    sleep 9 # required for this ^

    @payload.merge!({ main_account_id => ItauBalanceParser.new.parse(page.html) })
  end

  def scrape_savings
    login unless @logged_in
    puts "-----> Savings"

    click_on "Poupança"
    puts "pop"
    puts page.driver.network_traffic.inspect
    click_on "30 dias"
    find("#poupanca1").click
    click_on "CONTINUAR"

    puts current_url

    @payload.merge!({ savings_account_id => ItauSavingsParser.new.parse(page.html) })
  end

  def scrape
    scrape_balance rescue nil
    scrape_savings rescue nil

    @payload
  end

  def main_account_id
    ENV['GRANAIO_ITAU_MAIN_ACCOUNT'] || 'balance'
  end

  def savings_account_id
    ENV['GRANAIO_ITAU_SAVINGS_ACCOUNT'] || 'savings'
  end
end
