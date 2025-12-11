require "shoes"
require_relative "RPTLS"

Shoes.app(title: "Piedra - Papel - Tijera - Spock - Lagarto", width: 900, height: 900) do
  stack do
    para "Nombre jugador 1:"
    @n1_campo = edit_line

    para "Estrategia jugador 1:"
    @estrategia1_campo = edit_line

    para "Puntos jugador 1:"
    @puntos1_campo = edit_line :readonly => true

    para "Nombre jugador 2:"
    @n2_campo = edit_line

    para "Estrategia jugador 2:"
    @estrategia2_campo = edit_line

    para "Puntos jugador 2:"
    @puntos2_campo = edit_line :readonly => true

    para "Número de puntos o rondas:"
    @puntos_limite_campo = edit_line

    para "Modo de juego (Escribir Rondas o Puntos para seleccionar el modo de juego):"
    @modo_de_juego_campo = edit_line

    para "Rondas (No editable. Muestra el numero de rondas jugadas):"
    @rondas_campo = edit_line :readonly => true

    para "Puntos (No editable. Muestra el número de puntos necesarios para ganar):"
    @puntos_campo = edit_line :readonly => true

    para "Estado de la partida (No editable. Muestra si la partida acabó, quién gano o si quedó en empate):"
    @estado_de_la_partida = edit_line :readonly => true

    flow do
        stack do
            para "Jugada del jugador 1:"
            @jugada_jugador1_campo = edit_line :readonly => true
            @zona_img_j1 = stack(width: 100, height: 100)
        end

        stack do
            para "Jugada del jugador 2:"
            @jugada_jugador2_campo = edit_line :readonly => true
            @zona_img_j2 = stack(width: 100, height: 100)
        end
    end
    stack do
        button "Iniciar" do
            nombre1 = @n1_campo.text
            estrategia_jugador1 = MAPA_DE_STR_A_ESTRATEGIA[@estrategia1_campo.text]
            nombre2 = @n2_campo.text
            estrategia_jugador2 = MAPA_DE_STR_A_ESTRATEGIA[@estrategia2_campo.text]


            puntos  = @puntos_limite_campo.text.to_i            

            modo_str = @modo_de_juego_campo.text
            @modo_num = case modo_str
                        when "Rondas" then 0
                        when "Puntos" then 1
                        end

            @partida = Partida.new(nombre1, estrategia_jugador1, nombre2, estrategia_jugador2, @modo_num, puntos)
            @puntos1_campo.text = @partida.puntaje_jugador1.to_s
            @puntos2_campo.text = @partida.puntaje_jugador2.to_s
            @estado_de_la_partida.text = ""
            @jugada_jugador1_campo.text = ""
            @jugada_jugador2_campo.text = ""
            if @modo_num == 0
                @rondas_campo.text = @partida.rondas.to_s
            else
                @puntos_campo.text = @partida.modo_de_juego_limite.to_s
            end

            alert "¡A jugar! \n Presiona el boton 'Siguiente ronda' para comenzar a jugar."
            rescue => e
                alert "¡Recórcholis! \n Parece que no has escrito todos los parámetros de juego para iniciar la partida."
                puts "ERROR RUBY REAL -> #{e.class}: #{e.message}"
                puts e.backtrace
        end
    end
    stack do
        button "Siguiente ronda" do
            @partida.siguiente_ronda()
            @puntos1_campo.text = @partida.puntaje_jugador1.to_s
            @puntos2_campo.text = @partida.puntaje_jugador2.to_s
            @jugada_jugador1 = @partida.jugada_1.class
            @jugada_jugador2 = @partida.jugada_2.class
            @jugada_jugador1_campo.text = @partida.jugada_1.to_s
            @jugada_jugador2_campo.text = @partida.jugada_2.to_s

            if @modo_num == 0
                @rondas_campo.text = @partida.rondas.to_s
            else
                @puntos_campo.text = @partida.modo_de_juego_limite.to_s
            end

            if @partida.modo_de_juego == 0 and @partida.rondas == @partida.modo_de_juego_limite and @partida.puntaje_jugador1 > @partida.puntaje_jugador2
                @estado_de_la_partida.text = "Gana #{@partida.nombre_jugador1}"
            elsif @partida.modo_de_juego == 0 and @partida.rondas == @partida.modo_de_juego_limite and @partida.puntaje_jugador1 < @partida.puntaje_jugador2
                @estado_de_la_partida.text = "Gana #{@partida.nombre_jugador2}"
            elsif @partida.modo_de_juego == 0 and @partida.rondas == @partida.modo_de_juego_limite and @partida.puntaje_jugador1 == @partida.puntaje_jugador2
                @estado_de_la_partida.text = "Empate"
            elsif @partida.modo_de_juego == 1 and @partida.puntaje_jugador1 == @partida.modo_de_juego_limite
                @estado_de_la_partida.text = "Gana #{@partida.nombre_jugador1}"
            elsif @partida.modo_de_juego == 1 and @partida.puntaje_jugador2 == @partida.modo_de_juego_limite
                @estado_de_la_partida.text = "Gana #{@partida.nombre_jugador2}"
            elsif @partida.modo_de_juego == 1 and @partida.rondas == @partida.modo_de_juego_limite and @partida.puntaje_jugador1 == @partida.puntaje_jugador2
                @estado_de_la_partida.text = "Empate"
            else
                @estado_de_la_partida.text = "¡En curso!"
            end

            @zona_img_j1.clear do
                image "img/#{@partida.jugada_1}.png", width: 100, height: 100
            end

            @zona_img_j2.clear do
                image "img/#{@partida.jugada_2}.png", width: 100, height: 100
            end

            rescue => e
                alert "¡No valee! \n Debes escribir todos los parámetros de juego para iniciar y continuar una partida."
                puts "ERROR RUBY REAL -> #{e.class}: #{e.message}"
                puts e.backtrace
        end
    end
    end
end


