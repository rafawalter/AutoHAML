# language: pt
Funcionalidade: Conversão automática de HAML e SASS
  Para ser mais produtivo
  Como desenvolvedor web
  Eu quero que os arquivos html e css sejam gerados automaticamente

  Cenário: Processar arquivo HAML
    Dado que alterei um arquivo haml
    Quando autohaml verificar os arquivos
    Então vai ser gerado o arquivo html correspondente

  Cenário: Processar arquivo SASS
  	Dado que alterei um arquivo sass
    Quando autohaml verificar os arquivos
    Então vai ser gerado o arquivo css correspondente

  Cenário: Processar arquivo SCSS
		Dado que alterei um arquivo scss
	  Quando autohaml verificar os arquivos
    Então vai ser gerado o arquivo css correspondente
