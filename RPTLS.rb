class Estrategia
    @@semillaPadre = 42
end

class Jugada 
    def to_s()
        self.class.name
    end

    def puntos(contrincante)
        if self.class == contrincante.class
            [0, 0]
        elsif MAPA_DE_X_PIERDE_Y[self.class][0] == contrincante.class or MAPA_DE_X_PIERDE_Y[self.class][1] == contrincante.class
            [0, 1]
        else
            [1, 0]
        end
    end
end

class Piedra < Jugada 
end

class Papel < Jugada 
end

class Tijera < Jugada 
end

class Lagarto < Jugada 
end

class Spock < Jugada 
end


MAPA_DE_STR_A_CLASE = {
    "piedra" => Piedra,
    "papel" => Papel,
    "tijera" => Tijera,
    "lagarto" => Lagarto,
    "spock" => Spock
}

JUGADAS = [Piedra, Papel, Tijera, Lagarto, Spock]

MAPA_DE_PESOS = { Piedra => 50, Papel => 25, Tijera => 10, Lagarto => 20, Spock => 10 }

MAPA_DE_X_PIERDE_Y = { Papel => [Tijera, Lagarto], Piedra => [Papel, Spock], Lagarto => [Piedra, Tijera], Spock => [Lagarto, Papel], Tijera => [Spock, Piedra] } 

class Manual < Estrategia
    def prox()
        print "Inserte la próxima jugada: "
        jugada_str = gets.chomp.downcase
        if MAPA_DE_STR_A_CLASE.key?(jugada_str)
            jugada = MAPA_DE_STR_A_CLASE[jugada_str].new
        end
    end
end

class Uniforme < Estrategia
    def prox(lista)
        randIndex = rand(lista.length)
        jugada = lista[randIndex].new
    end

end

class Sesgada < Estrategia
    def prox(opciones)
        pesos_acumulados = []
        suma_actual = 0
        opciones.each do |elemento, peso|
            suma_actual += peso
            pesos_acumulados << [suma_actual, elemento]
        end

        total_peso = suma_actual
        
        # 2. Generar un número aleatorio entre 0 y el peso total
        r = rand(total_peso)

        # 3. Encontrar el elemento cuyo peso acumulado supera a 'r'
        pesos_acumulados.each do |peso_limite, elemento|
            return elemento.new if r < peso_limite
        end
    end
end

class Copiar < Estrategia
    def prox(jugada_oponente)
        if jugada_oponente.nil?
            rndIndex = rand(JUGADAS.length)
            JUGADAS[rndIndex].new
        else
            jugada_oponente
        end
        
    end
end

class Pensar < Estrategia

    def prox(historico_jugadas_contrincante)
        mayor_frecuencia = 0
        jugada_frecuente = nil
        historico_jugadas_contrincante.each do |jugada, frecuencia|
            if mayor_frecuencia < frecuencia
                mayor_frecuencia = frecuencia
                jugada_frecuente = jugada
            end    
        end

        if jugada_frecuente.nil?
            randIndex = rand(JUGADAS.length)
            jugada_frecuente = JUGADAS[randIndex]
        end

        mejores_jugadas = MAPA_DE_X_PIERDE_Y[jugada_frecuente]
        randIndex = rand(mejores_jugadas.length)
        mejor_jugada = mejores_jugadas[randIndex].new

    end
end

MAPA_DE_STR_A_ESTRATEGIA = {
    "Manual" => Manual,
    "Uniforme" => Uniforme,
    "Sesgada" => Sesgada,
    "Copiar" => Copiar,
    "Pensar" => Pensar
}

class Partida
    attr_accessor :nombre_jugador1, :estrategia_jugador1,
                :nombre_jugador2, :estrategia_jugador2,
                :modo_de_juego, :modo_de_juego_limite,
                :puntaje_jugador1, :puntaje_jugador2,
                :rondas, :partida_acabada, 
                :ultima_jugada1, :ultima_jugada2,
                :historico_jugadas_jugador1, :historico_jugadas_jugador2,
                :jugada_1, :jugada_2, :ganador, :perdedor, :empate

    def initialize (nombre_jugador1, estrategia_jugador1, nombre_jugador2, estrategia_jugador2, modo_de_juego, modo_de_juego_limite)
        @nombre_jugador1 = nombre_jugador1
        @estrategia_jugador1 = estrategia_jugador1.new

        @nombre_jugador2 = nombre_jugador2
        @estrategia_jugador2 = estrategia_jugador2.new

        @modo_de_juego        = modo_de_juego
        @modo_de_juego_limite = modo_de_juego_limite

        @puntaje_jugador1 = 0
        @puntaje_jugador2 = 0
        @rondas           = 0
        @partida_acabada  = false

        @jugada_1 = nil
        @jugada_2 = nil

        @ultima_jugada1 = nil
        @ultima_jugada2 = nil

        @historico_jugadas_jugador1 = { Piedra => 0, Papel => 0, Tijera => 0, Spock => 0, Lagarto => 0 }
        @historico_jugadas_jugador2 = { Piedra => 0, Papel => 0, Tijera => 0, Spock => 0, Lagarto => 0 }
        

        @ganador = ""
        @perdedor = ""
        @empate = false
    end
    def cambiar_estrategia(estrategia, jugador)
        if jugador === 1 
            @estrategia_jugador1 = estrategia.new
        else
            @estrategia_jugador2 = estrategia.new
        end
    end
    def siguiente_ronda()
        if @partida_acabada == false
            estrategia1 = @estrategia_jugador1.class
            estrategia2 = @estrategia_jugador2.class
            if estrategia1 == Uniforme
                @jugada_1 = @estrategia_jugador1.prox(JUGADAS)
            elsif estrategia1 == Manual
                @jugada_1 = @estrategia_jugador1.prox()
            elsif estrategia1 == Sesgada
                @jugada_1 = @estrategia_jugador1.prox(MAPA_DE_PESOS)
            elsif estrategia1 == Copiar
                @jugada_1 = @estrategia_jugador1.prox(@ultima_jugada2)
                puts "Jugada del jugador 1 #{@jugada_1}"
            elsif estrategia1 == Pensar
                @jugada_1 = @estrategia_jugador1.prox(@historico_jugadas_jugador2)
            end

            if estrategia2 == Uniforme
                @jugada_2 = @estrategia_jugador2.prox(JUGADAS)
            elsif estrategia2 == Manual
                @jugada_2 = @estrategia_jugador2.prox()
            elsif estrategia2 == Sesgada
                @jugada_2 = @estrategia_jugador2.prox(MAPA_DE_PESOS)
            elsif estrategia2 == Copiar
                @jugada_2 = @estrategia_jugador2.prox(@ultima_jugada1)
                puts "Jugada del jugador 2 #{@jugada_2}"
            elsif estrategia2 == Pensar
                @jugada_2 = @estrategia_jugador2.prox(@historico_jugadas_jugador1)
            end
            #Valores para la estrategia Copiar
            @ultima_jugada2 = @jugada_2
            @ultima_jugada1 = @jugada_1
            
            #Actualizar histórico de jugadas del jugador 1 para el jugador 2
            @historico_jugadas_jugador1[@jugada_1.class] = @historico_jugadas_jugador1[@jugada_1.class] + 1
            #Actualizar histórico de jugadas del jugador 2 para el jugador 1
            @historico_jugadas_jugador2[@jugada_2.class] = @historico_jugadas_jugador2[@jugada_2.class] + 1
            

            resultado = @jugada_1.puntos(@jugada_2)
            
            if resultado == [1, 0]
                @puntaje_jugador1 = @puntaje_jugador1 + 1
            elsif resultado == [0, 1]
                @puntaje_jugador2 = @puntaje_jugador2 + 1
            end

            puts "Estrategias:\n P1: #{@jugada_1}, P2: #{@jugada_2}"
            puts "Resultado de la ronda:\n P1: #{@puntaje_jugador1}, P2: #{@puntaje_jugador2}"

            @rondas = @rondas + 1

            if @modo_de_juego == 0 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 > @puntaje_jugador2
                puts "Gana #{@nombre_jugador1}"
                @partida_acabada = true
                @ganador = @nombre_jugador1
                @perdedor = @nombre_jugador2
            elsif @modo_de_juego == 0 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 < @puntaje_jugador2
                puts "Gana #{@nombre_jugador2}"
                @partida_acabada = true
                @ganador = @nombre_jugador1
                @perdedor = @nombre_jugador2
            elsif @modo_de_juego == 0 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 == @puntaje_jugador2
                puts "¡Empate!"
                @partida_acabada = true
                @empate = true
            elsif @modo_de_juego == 1 and @puntaje_jugador1 == @modo_de_juego_limite
                puts "Gana #{@nombre_jugador1}"
                @partida_acabada = true
                @ganador = @nombre_jugador1
                @perdedor = @nombre_jugador2
            elsif @modo_de_juego == 1 and @puntaje_jugador2 == @modo_de_juego_limite
                puts "Gana #{@nombre_jugador2}"
                @partida_acabada = true
                @ganador = @nombre_jugador2
                @perdedor = @nombre_jugador1
            elsif @modo_de_juego == 1 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 == @puntaje_jugador2
                puts "¡Empate!"
                @partida_acabada = true
                @empate = true
            end
        else
            puts "¡Partida acabada!"
        end
    end
    def alcanzar()
        estrategia1 = @estrategia_jugador1.class
        estrategia2 = @estrategia_jugador2.class
        loop do
            if estrategia1 == Uniforme
                @jugada_1 = @estrategia_jugador1.prox(JUGADAS)
            elsif estrategia1 == Manual
                @jugada_1 = @estrategia_jugador1.prox()
            elsif estrategia1 == Sesgada
                @jugada_1 = @estrategia_jugador1.prox(MAPA_DE_PESOS)
            elsif estrategia1 == Copiar
                @jugada_1 = @estrategia_jugador1.prox(ultima_jugada2)
            elsif estrategia1 == Pensar
                @jugada_1 = @estrategia_jugador1.prox(@historico_jugadas_jugador2)
            end

            if estrategia2 == Uniforme
                @jugada_2 = @estrategia_jugador2.prox(JUGADAS)
            elsif estrategia2 == Manual
                @jugada_2 = @estrategia_jugador2.prox()
            elsif estrategia2 == Sesgada
                @jugada_2 = @estrategia_jugador2.prox(MAPA_DE_PESOS)
            elsif estrategia2 == Copiar
                @jugada_2 = @estrategia_jugador2.prox(ultima_jugada1)
            elsif estrategia2 == Pensar
                @jugada_2 = @estrategia_jugador2.prox(@historico_jugadas_jugador1)
            end

            if (estrategia1 == Copiar)
                ultima_jugada2 = @jugada_2
            end
            if (estrategia2 == Copiar)
                ultima_jugada1 = @jugada_1
            end
            
            #Actualizar histórico de jugadas del jugador 2 para el jugador 1
            @historico_jugadas_jugador2[@jugada_2.class] += 1
            
            #Actualizar histórico de jugadas del jugador 1 para el jugador 2
            @historico_jugadas_jugador1[@jugada_1.class] += 1

            resultado = @jugada_1.puntos(@jugada_2)
            
            if resultado == [1, 0]
                @puntaje_jugador1 = @puntaje_jugador1 + 1
            elsif resultado == [0, 1]
                @puntaje_jugador2 = @puntaje_jugador2 + 1
            end

            puts "Estrategias:\n P1: #{@jugada_1}, P2: #{@jugada_2}"
            puts "Resultado de la ronda:\n P1: #{@puntaje_jugador1}, P2: #{@puntaje_jugador2}"

            @rondas = @rondas + 1

            if @modo_de_juego == 0 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 > @puntaje_jugador2
                puts "Gana #{@nombre_jugador1}"
                @partida_acabada = true
                break
            elsif @modo_de_juego == 0 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 < @puntaje_jugador2
                puts "Gana #{@nombre_jugador2}"
                @partida_acabada = true
                break
            elsif @modo_de_juego == 0 and @rondas == @modo_de_juego_limite and @puntaje_jugador1 == @puntaje_jugador2
                puts "¡Empate!"
                @partida_acabada = true
                break
            elsif @modo_de_juego == 1 and @puntaje_jugador1 == @modo_de_juego_limite
                puts "Gana #{@nombre_jugador1}"
                @partida_acabada = true
                break
            elsif @modo_de_juego == 1 and @puntaje_jugador2 == @modo_de_juego_limite
                puts "Gana #{@nombre_jugador2}"
                @partida_acabada = true
                break
            end
        end
    end
end

# partida = Partida.new("Mauricio", Copiar, "Alan", Copiar, 0, 3)
# partida.siguiente_ronda()
# partida.siguiente_ronda()
# partida.siguiente_ronda()
# partida.siguiente_ronda()
# partida.siguiente_ronda()
# partida.siguiente_ronda()