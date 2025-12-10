require_relative 'RPTLS'
require 'shoes'

# Simple Shoes 4 GUI for RPTLS game
# Designed for JRuby + Shoes (Shoes4). Does not modify RPTLS.rb.

def strategy_instance_from_name(name)
  case name
  when 'Manual' then Manual.new
  when 'Uniforme' then Uniforme.new
  when 'Sesgada' then Sesgada.new
  when 'Copiar' then Copiar.new
  when 'Pensar' then Pensar.new
  else Pensar.new
  end
end

MOVES_EMOJI = {
  Piedra => '✊',
  Papel => '✋',
  Tijera => '✌️',
  Lagarto => '🦎',
  Spock => '🖖'
}

Shoes.app(title: 'RPTLS - GUI', width: 900, height: 520) do
  background gradient(white, '#f0f6ff')

  stack(margin: 12) do
    flow do
      caption "RPTLS - Rock/Paper/Tijera/Lagarto/Spock", align: "center"
    end

    flow(margin_top: 8) do
      # Two-column layout for player configuration
      stack(width: 0.5) do
        para 'Jugador 1'
        flow do
          para 'Nombre: '
          @name1 = edit_line width: 180
        end
        flow do
          para 'Estrategia: '
          @strat1 = list_box items: ['Manual', 'Uniforme', 'Sesgada', 'Copiar', 'Pensar']
          @strat1.text = 'Pensar'
        end
        flow do
          para 'Parámetros Uniforme: '
          @uniform_param_1 = edit_line width: 200
          @uniform_param_1.text = ''
        end
        flow do
          para 'Pesos Sesgada: '
          @sesgada_param_1 = edit_line width: 200
          @sesgada_param_1.text = 'piedra:50,papel:25,tijera:10,lagarto:20,spock:10'
        end
      end

      stack(width: 0.5) do
        para 'Jugador 2'
        flow do
          para 'Nombre: '
          @name2 = edit_line width: 180
        end
        flow do
          para 'Estrategia: '
          @strat2 = list_box items: ['Manual', 'Uniforme', 'Sesgada', 'Copiar', 'Pensar']
          @strat2.text = 'Pensar'
        end
        flow do
          para 'Parámetros Uniforme: '
          @uniform_param_2 = edit_line width: 200
          @uniform_param_2.text = ''
        end
        flow do
          para 'Pesos Sesgada: '
          @sesgada_param_2 = edit_line width: 200
          @sesgada_param_2.text = 'piedra:50,papel:25,tijera:10,lagarto:20,spock:10'
        end
      end
    end

    flow(margin_top: 6) do
      para 'Modo de juego: '
      @mode_select = list_box items: ['Rondas', 'Alcanzar']
      @mode_select.text = 'Rondas'

      para ' Límite N: '
      @limit = edit_line width: 80
      @limit.text = '10'

      para ' '
      @start_btn = button 'Iniciar partida', margin_left: 12 do
        start_game
      end
    end

    stack margin_top: 12 do
      flow do
        @left_panel = stack(width: 300) do
          background '#ffffff'
          @p1_title = para 'Jugador 1', align: 'center'
          @p1_move = para '', align: 'center', size: 56
          @p1_move_name = para '', align: 'center', size: 18
          @p1_score = para 'Puntaje: 0', align: 'center', size: 16
        end

        @center_panel = stack(width: 300) do
          background '#ffffff'
          @round_label = para 'Ronda: 0', align: 'center', size: 20
          @match_info = para '', align: 'center', size: 14
          @next_btn = button 'Siguiente ronda', width: 200, margin_top: 18 do
            play_round
          end
          @next_btn.hidden = true
          @manual_choice_p1 = list_box items: ['piedra','papel','tijera','lagarto','spock'], hidden: true
          @manual_choice_p2 = list_box items: ['piedra','papel','tijera','lagarto','spock'], hidden: true
        end

        @right_panel = stack(width: 300) do
          background '#ffffff'
          @p2_title = para 'Jugador 2', align: 'center'
          @p2_move = para '', align: 'center', size: 56
          @p2_move_name = para '', align: 'center', size: 18
          @p2_score = para 'Puntaje: 0', align: 'center', size: 16
        end
      end
    end

    flow(margin_top: 12) do
      @status = para '', align: 'center', size: 14
    end
  end

  # Internal game state
  @partida = nil
  @p1_strategy = nil
  @p2_strategy = nil
  @ultima_jugada1 = nil
  @ultima_jugada2 = nil
  @puntaje1 = 0
  @puntaje2 = 0
  @rondas = 0
  @modo = 0
  @limite = 10

  def start_game
    @puntaje1 = 0
    @puntaje2 = 0
    @rondas = 0

    # read inputs
    name1 = @name1.text.strip
    name2 = @name2.text.strip
    name1 = 'Jugador 1' if name1.empty?
    name2 = 'Jugador 2' if name2.empty?

    @p1_name = name1
    @p2_name = name2

    @p1_strategy = strategy_instance_from_name(@strat1.text)
    @p2_strategy = strategy_instance_from_name(@strat2.text)

    @modo = (@mode_select.text == 'Alcanzar') ? 1 : 0
    begin
      @limite = Integer(@limit.text)
    rescue
      @limite = 10
      @limit.text = '10'
    end

    # show manual selectors only if needed
    @manual_choice_p1.hidden = !(@strat1.text == 'Manual')
    @manual_choice_p2.hidden = !(@strat2.text == 'Manual')

    # hide/show parameter fields depending on strategy
    @uniform_param_1.hidden = !(@strat1.text == 'Uniforme')
    @sesgada_param_1.hidden = !(@strat1.text == 'Sesgada')
    @uniform_param_2.hidden = !(@strat2.text == 'Uniforme')
    @sesgada_param_2.hidden = !(@strat2.text == 'Sesgada')

    @p1_title.replace "#{@p1_name} (#{@strat1.text})"
    @p2_title.replace "#{@p2_name} (#{@strat2.text})"
    @p1_score.replace "Puntaje: 0"
    @p2_score.replace "Puntaje: 0"
    @round_label.replace "Ronda: 0"
    @status.replace ''
    @p1_move.replace ''
    @p2_move.replace ''
    @p1_move_name.replace ''
    @p2_move_name.replace ''

    # initialize Pensar instances to keep their internal state
    if @p1_strategy.is_a?(Pensar)
      @p1_strategy = Pensar.new
    end
    if @p2_strategy.is_a?(Pensar)
      @p2_strategy = Pensar.new
    end

    # wire strategy selectors to show/hide manual choices dynamically
    @strat1.change do
      @manual_choice_p1.hidden = !(@strat1.text == 'Manual')
      @uniform_param_1.hidden = !(@strat1.text == 'Uniforme')
      @sesgada_param_1.hidden = !(@strat1.text == 'Sesgada')
      @p1_title.replace "#{@p1_name} (#{@strat1.text})"
    end
    @strat2.change do
      @manual_choice_p2.hidden = !(@strat2.text == 'Manual')
      @uniform_param_2.hidden = !(@strat2.text == 'Uniforme')
      @sesgada_param_2.hidden = !(@strat2.text == 'Sesgada')
      @p2_title.replace "#{@p2_name} (#{@strat2.text})"
    end

    # show next button and mark game started
    @next_btn.hidden = false
    @game_started = true
  end

  def play_round
    # safety: require partida started
    unless @game_started
      @status.replace 'Inicie la partida primero.'
      return
    end
    # determine move for player 1
    jugada_1 = nil
    jugada_2 = nil

    # Helper: parse uniform choices text into array of classes
    parse_uniform = lambda do |text|
      return JUGADAS if text.nil? or text.strip.empty?
      names = text.split(',').map(&:strip).map(&:downcase)
      classes = []
      names.each do |n|
        if MAPA_DE_STR_A_CLASE.key?(n)
          classes << MAPA_DE_STR_A_CLASE[n]
        end
      end
      classes.empty? ? JUGADAS : classes
    end

    # Helper: parse sesgada text into hash {Class => weight}
    parse_sesgada = lambda do |text|
      begin
        pairs = text.split(',').map(&:strip)
        h = {}
        pairs.each do |p|
          k,v = p.split(':').map(&:strip)
          next if k.nil? or v.nil?
          if MAPA_DE_STR_A_CLASE.key?(k.downcase)
            h[MAPA_DE_STR_A_CLASE[k.downcase]] = Integer(v) rescue 0
          end
        end
        h.empty? ? MAPA_DE_PESOS : h
      rescue
        MAPA_DE_PESOS
      end
    end

    # Player 1
    case @strat1.text
    when 'Uniforme'
      lista = parse_uniform.call(@uniform_param_1.text)
      jugada_1 = @p1_strategy.prox(lista)
    when 'Manual'
      choice = @manual_choice_p1.text || 'piedra'
      klass = MAPA_DE_STR_A_CLASE[choice]
      jugada_1 = klass.new
    when 'Sesgada'
      mapa_param = parse_sesgada.call(@sesgada_param_1.text)
      jugada_1 = @p1_strategy.prox(mapa_param)
    when 'Copiar'
      res = @p1_strategy.prox(@ultima_jugada2)
      jugada_1 = res.is_a?(Class) ? res.new : res
    when 'Pensar'
      jugada_1 = @p1_strategy.prox()
    else
      jugada_1 = @p1_strategy.prox()
    end

    # Player 2
    case @strat2.text
    when 'Uniforme'
      lista = parse_uniform.call(@uniform_param_2.text)
      jugada_2 = @p2_strategy.prox(lista)
    when 'Manual'
      choice = @manual_choice_p2.text || 'piedra'
      klass = MAPA_DE_STR_A_CLASE[choice]
      jugada_2 = klass.new
    when 'Sesgada'
      mapa_param = parse_sesgada.call(@sesgada_param_2.text)
      jugada_2 = @p2_strategy.prox(mapa_param)
    when 'Copiar'
      res = @p2_strategy.prox(@ultima_jugada1)
      jugada_2 = res.is_a?(Class) ? res.new : res
    when 'Pensar'
      jugada_2 = @p2_strategy.prox()
    else
      jugada_2 = @p2_strategy.prox()
    end

    # Update copia/pensar history as original logic does
    if @strat1.text == 'Copiar'
      @ultima_jugada2 = jugada_2
    end
    if @strat2.text == 'Copiar'
      @ultima_jugada1 = jugada_1
    end
    if @strat1.text == 'Pensar'
      frecuencia_actual = @p1_strategy.historico_jugadas_contrincante[jugada_2.class]
      @p1_strategy.historico_jugadas_contrincante[jugada_2.class] = frecuencia_actual + 1
    end
    if @strat2.text == 'Pensar'
      frecuencia_actual = @p2_strategy.historico_jugadas_contrincante[jugada_1.class]
      @p2_strategy.historico_jugadas_contrincante[jugada_1.class] = frecuencia_actual + 1
    end

    # compute points
    resultado = jugada_1.puntos(jugada_2)
    if resultado == [1,0]
      @puntaje1 += 1
    elsif resultado == [0,1]
      @puntaje2 += 1
    end

    @rondas += 1

    # display moves
    emoji1 = MOVES_EMOJI[jugada_1.class] || jugada_1.class.name
    emoji2 = MOVES_EMOJI[jugada_2.class] || jugada_2.class.name
    @p1_move.replace emoji1
    @p2_move.replace emoji2
    @p1_move_name.replace jugada_1.to_s
    @p2_move_name.replace jugada_2.to_s
    @p1_score.replace "Puntaje: #{@puntaje1}"
    @p2_score.replace "Puntaje: #{@puntaje2}"
    @round_label.replace "Ronda: #{@rondas}"
    @match_info.replace "P1: #{jugada_1}, P2: #{jugada_2}"

    # check end condition
    ended = false
    if @modo == 0
      if @rondas >= @limite
        ended = true
      end
    else
      if @puntaje1 >= @limite or @puntaje2 >= @limite
        ended = true
      end
    end

    if ended
      if @puntaje1 > @puntaje2
        @status.replace "Gana #{@p1_name}!"
      elsif @puntaje2 > @puntaje1
        @status.replace "Gana #{@p2_name}!"
      else
        @status.replace "¡Empate!"
      end
      @next_btn.hidden = true
      @game_started = false
    else
      @status.replace ''
    end
  end
end
