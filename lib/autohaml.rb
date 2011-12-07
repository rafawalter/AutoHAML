require 'find'

class AutoHaml
  IDLE_SECONDS = 1
  SLEEP_SECONDS = 1
  
  def initialize(pasta_base = '.', pasta_destino = '.', log = true, debug = false)
    @processamentos = {
      :haml => :montar_comando_haml,
      :sass => :montar_comando_sass,
      :scss => :montar_comando_sass
    }
    @extensoes = @processamentos.keys.collect {|key| '.'+key.to_s}
    @pasta_base = pasta_base
    @pasta_destino = pasta_destino    
    @ultima_pesquisa ||= Time.now	
	@log ||= log
	@debug ||= debug
	
	log "Monitorando a pasta #{@pasta_base}"
	log "Gerando na pasta #{@pasta_destino}"
  end

  def monitorar
	idle_feedback, idle_feedback_unused = '.', '-'
    while (true) do
      sleep(SLEEP_SECONDS)
      arquivos_processados = verificar_arquivos
	  if arquivos_processados != 0
		print "\n" 			
		idle_feedback, idle_feedback_unused = idle_feedback_unused, idle_feedback
	  end
	  print idle_feedback
    end    
  end
  
  def verificar_arquivos
    arquivos_processados = 0
    total_de_arquivos = 0
    Dir.glob(File.join(@pasta_base,'**','*')) do |path|
      debug path
      if @extensoes.include?(File.extname(path))
        ultima_alteracao = File.mtime path
        debug "#{ultima_alteracao} - #{@ultima_pesquisa} = #{ultima_alteracao.to_f - @ultima_pesquisa.to_f}"
        if (ultima_alteracao.to_f - @ultima_pesquisa.to_f) >= -IDLE_SECONDS
          comando = montar_comando path
          executar comando
          arquivos_processados += 1		  
        end
      end
      total_de_arquivos += 1
    end
    @ultima_pesquisa = Time.now
	arquivos_processados
  end
  
  def executar(comando)
    log "#{Time.now} Executando: #{comando}"
    `#{comando}`
  end
  
  def montar_comando(path)
    extensao = File.extname(path).gsub('.','').to_sym
    comando = @processamentos[extensao]
    raise "Comando desconhecido para o arquivo [#{path}]" if comando.nil?
    send(comando, path)
  end
  
  def montar_comando_haml(path)
    arquivo_html = path.gsub(@pasta_base, @pasta_destino).gsub('.haml', '.html')
    "haml #{path} #{arquivo_html}"
  end
  
  def montar_comando_sass(path)
    arquivo_html = path.gsub(@pasta_base, @pasta_destino).gsub(/\.s[ac]ss/, '.css')
    "sass #{path} #{arquivo_html}"
  end
  
  def log(texto)
    puts texto if @log || @debug
  end
  
  def debug(texto)
    puts texto if @debug
  end
end

if $0 == __FILE__
  AutoHaml.new.monitorar
end

