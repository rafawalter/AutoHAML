require 'find'
require 'fileutils'


class AutoHaml
  IDLE_SECONDS = 1
  SLEEP_SECONDS = 1
  
  def initialize(pasta_base = '.', pasta_destino = File.join('.', 'public'), log = true, debug = false)
    @comandos = {
      :haml => :processar_haml,
      [:sass, :scss] => :processar_sass,
	  :less => :copiar_arquivo,
	  [:jpg,:png,:gif] => :copiar_arquivo,
	  [:js,:json] => :copiar_arquivo,
	  :csv => :copiar_arquivo,
    }
	@comando_por_extensao = expandir_comandos(@comandos)
    @extensoes = obter_extensoes(@comandos)
    @pasta_base = pasta_base
    @pasta_destino = pasta_destino    
    @ultima_pesquisa ||= Time.now	
	@log ||= log
	@debug ||= debug
	
	log "Monitorando a pasta #{@pasta_base}"
	log "Gerando na pasta #{@pasta_destino}"
	log @comando_por_extensao
	log @extensoes
  end
  
  def expandir_comandos(hash)
	comandos_expandidos = {}
	hash.each { |key,comando|
		if (key.is_a? Array)
			key.each {|subkey| comandos_expandidos[subkey] = comando }
		else 
			comandos_expandidos[key] = comando
		end
	}
	
	comandos_expandidos
  end
  
  def obter_extensoes(hash)
	hash.keys.collect { |key| 
		if (key.is_a? Array)
			extensoes = key.collect {|subkey| '.' + subkey.to_s }
		else 
			extensoes = '.'+key.to_s
		end
		
		extensoes
	}.flatten
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
	inicio_desta_pesquisa = Time.now
    arquivos_processados = 0
    total_de_arquivos = 0
    Dir.glob(File.join(@pasta_base,'**','*')) do |path|
	  next if (path =~ /\.\/lib\// || path =~ Regexp.new(@pasta_destino) || path =~ /\.\/spec\//)
	  
      debug path
      if @extensoes.include?(File.extname(path))
		if File.exists?(path)
			ultima_alteracao = File.mtime path
			debug "#{ultima_alteracao} - #{@ultima_pesquisa} = #{ultima_alteracao.to_f - @ultima_pesquisa.to_f}"
			if (ultima_alteracao.to_f - @ultima_pesquisa.to_f) >= -IDLE_SECONDS
			  comando = montar_comando path
			  executar comando
			  arquivos_processados += 1		  
			end
		end
      end
      total_de_arquivos += 1
    end
    @ultima_pesquisa = inicio_desta_pesquisa
	arquivos_processados
  end
  
  def executar(comando)
    log "#{Time.now} Executando: #{comando}"
    `#{comando}`
  end
  
  def montar_comando(path)
    extensao = File.extname(path).gsub('.','').to_sym
    comando = @comando_por_extensao[extensao]
    raise "Comando desconhecido para o arquivo [#{path}]" if comando.nil?
    send(comando, path)
  end
  
  def processar_haml(path)
    arquivo_destino = path.sub(@pasta_base, @pasta_destino).sub('.haml', '')
	garantir_que_pasta_existe arquivo_destino
    "haml #{path} #{arquivo_destino}"
  end
  
  def processar_sass(path)
    arquivo_destino = path.sub(@pasta_base, @pasta_destino).sub(/\.s[ac]ss/, '')
    "sass #{path} #{arquivo_destino}"
  end
  
  def copiar_arquivo(path)
	arquivo_destino = path.sub(@pasta_base, @pasta_destino)
	"copy #{path} #{arquivo_destino}".gsub(/\//,"\\")
  end
  
  def garantir_que_pasta_existe(path)
	pasta = File.dirname(path)
	FileUtils.mkpath( pasta ) unless File.exists?( pasta )
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

