# encoding: utf-8
require 'fileutils'

require 'autohaml'

PASTA_ORIGEM = './resources'
PASTA_DESTINO = './temp'

Before do
  @autohaml = AutoHaml.new(PASTA_ORIGEM, PASTA_DESTINO)
  FileUtils.rm_rf PASTA_DESTINO if File.exists?(PASTA_DESTINO) && File.directory?(PASTA_DESTINO)
  FileUtils.mkdir_p PASTA_DESTINO
end

After do
end

def ler_arquivo caminho
  conteudo = ''
  File.foreach(caminho) do |linha| 
     conteudo += linha
   end
  conteudo
end

Dado /^que alterei um arquivo haml$/ do
  FileUtils.touch File.join(PASTA_ORIGEM, 'hello.haml')
end

Quando /^autohaml verificar os arquivos$/ do
  @autohaml.verificar_arquivos
end

Então /^vai ser gerado o arquivo html correspondente$/ do
  conteudo_gerado = ler_arquivo File.join(PASTA_DESTINO, 'hello.html')
  conteudo_esperado = ler_arquivo File.join(PASTA_ORIGEM, 'hello_esperado.html')
  
  conteudo_gerado.should == conteudo_esperado
end

Dado /^que alterei um arquivo sass$/ do
  FileUtils.touch File.join(PASTA_ORIGEM, 'hello.sass')
end

Dado /^que alterei um arquivo scss$/ do
  FileUtils.touch File.join(PASTA_ORIGEM, 'hello.scss')
end

Então /^vai ser gerado o arquivo css correspondente$/ do
  conteudo_gerado = ler_arquivo File.join(PASTA_DESTINO, 'hello.css')
  conteudo_esperado = ler_arquivo File.join(PASTA_ORIGEM, 'hello_esperado.css')
  
  conteudo_gerado.should == conteudo_esperado
end
