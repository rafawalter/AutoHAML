require 'find'

class AutoHaml
  def initialize(caminho_base = '.')
    @processamentos = {
      :haml => :montar_comando_haml,
      :sass => :montar_comando_sass,
      :scss => :montar_comando_sass
    }
    @extensoes = @processamentos.keys.collect {|key| '.'+key.to_s}
    @caminho_base = caminho_base
    @ultima_pesquisa ||= Time.now
  end

  def monitorar
    while (true) do
      verificar_arquivos @caminho_base
      sleep(3)
    end    
  end
  
  def verificar_arquivos(caminho_base)
    arquivos_processados = 0
    total_de_arquivos = 0
    Find.find(caminho_base) do |path|
      if @extensoes.include?(File.extname(path))
        ultima_alteracao = File.mtime path
        if ultima_alteracao > @ultima_pesquisa
          comando = montar_comando path
          executar comando
          arquivos_processados += 1
        end
      end
      total_de_arquivos += 1
    end
    @ultima_pesquisa = Time.now
  end
  
  def executar(comando)
    log "Executando: #{comando}"
    `#{comando}`
  end
  
  def montar_comando(path)
    extensao = File.extname(path).gsub('.','').to_sym
    comando = @processamentos[extensao]
    raise "Comando desconhecido para o arquivo [#{path}]" if comando.nil?
    send(comando, path)
  end
  
  def montar_comando_haml(path)
    arquivo_html = path.gsub('.haml', '.html')
    "haml #{path} #{arquivo_html}"
  end
  
  def montar_comando_sass(path)
    arquivo_html = path.gsub(/\.s[ac]ss/, '.css')
    "sass #{path} #{arquivo_html}"
  end
  
  def log(texto)
    puts texto
  end
end

AutoHaml.new.monitorar

