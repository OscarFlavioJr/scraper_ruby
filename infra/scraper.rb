#infra/scraper
require 'selenium-webdriver'
require 'nokogiri'

driver = Selenium::WebDriver.for :chrome
driver.get("https://www.vagas.com.br/vagas-de-fleury")

#Como o botão reaparece na página, adicionar um loop irá apertá-lo até não ter mais!
loop do 
botaoMais = driver.find_element(id: 'maisVagas')
driver.execute_script("arguments[0].scrollIntoView(true)", botaoMais)
#Através de JS, colocamos a div em posição 0 (menor possível) e é clicado automaticamente!
driver.execute_script("arguments[0].click();", botaoMais)
sleep 2
#Evita que o código quebre quando as vagas forem encerradas!
rescue Selenium::WebDriver::Error::NoSuchElementError
    puts "Todas as vagas já foram carregadas!"
    break
end

#pegamos o HTML do selenium e o atríbuímos à uma variável!
html = driver.page_source

document = Nokogiri::HTML(html)

vagas = document.css("div.informacoes-header")

dados = vagas.map do |vaga|{
    cargo: vaga.at_css("h2.cargo")&.text&.strip,
    link: "https://www.vagas.com.br#{vaga.at_css("h2.cargo a.link-detalhes-vaga")&.[]("href")}"
}
end

dados.each do |vaga| 
    puts "Cargo: #{vaga[:cargo]}"
    puts "Link: #{vaga[:link]}"
end

File.open("vagas.json", "w") do |f|
    f.write(JSON.pretty_generate(dados))
  end
  
  puts "#{dados.size} vagas disponíveis."
  driver.quit