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
            JUGADAS[rndIndex]
        else
            jugada_oponente
        end
        
    end
end

class Pensar < Estrategia
    attr_accessor :historico_jugadas_contrincante
    attr_reader :historico_jugadas_contrincante

    def initialize()
        @historico_jugadas_contrincante = { Piedra => 0, Papel => 0, Tijera => 0, Spock => 0, Lagarto => 0 }
    end
    def prox()
        mayor_frecuencia = 0
        jugada_frecuente = nil
        @historico_jugadas_contrincante.each do |jugada, frecuencia|
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

class Partida
    @@nombre_jugador1 = "Pepe"
    @@estrategia_jugador1 = Pensar.new
    @@nombre_jugador2 = "Popo"
    @@estrategia_jugador2 = Pensar.new
    @@modo_de_juego = 0
    @@modo_de_juego_limite = 100
    @@puntaje_jugador1 = 0
    @@puntaje_jugador2 = 0
    @@rondas = 0

    def iniciar_partida()
        ultima_jugada1 = nil
        ultima_jugada2 = nil
        estrategia1 = @@estrategia_jugador1.class
        estrategia2 = @@estrategia_jugador2.class
        loop do

            if estrategia1 == Uniforme
                jugada_1 = @@estrategia_jugador1.prox(JUGADAS)
            elsif estrategia1 == Manual or estrategia1 == Pensar
                jugada_1 = @@estrategia_jugador1.prox()
            elsif estrategia1 == Sesgada
                jugada_1 = @@estrategia_jugador1.prox(MAPA_DE_PESOS)
            elsif estrategia1 == Copiar
                jugada_1 = @@estrategia_jugador1.prox(ultima_jugada2)
            end

            if estrategia2 == Uniforme
                jugada_2 = @@estrategia_jugador2.prox(JUGADAS)
            elsif estrategia2 == Manual or estrategia2 == Pensar
                jugada_2 = @@estrategia_jugador2.prox()
            elsif estrategia2 == Sesgada
                jugada_2 = @@estrategia_jugador2.prox(MAPA_DE_PESOS)
            elsif estrategia2 == Copiar
                jugada_2 = @@estrategia_jugador2.prox(ultima_jugada1)
            end

            if (estrategia1 == Copiar)
                ultima_jugada2 = jugada_2
            end
            if (estrategia2 == Copiar)
                ultima_jugada1 = jugada_1
            end
            if (estrategia1 == Pensar)
                frecuencia_actual = @@estrategia_jugador1.historico_jugadas_contrincante[jugada_2.class] 
                @@estrategia_jugador1.historico_jugadas_contrincante[jugada_2.class] = frecuencia_actual + 1
            end
            if (estrategia2 == Pensar)
                frecuencia_actual = @@estrategia_jugador2.historico_jugadas_contrincante[jugada_1.class] 
                @@estrategia_jugador2.historico_jugadas_contrincante[jugada_1.class] = frecuencia_actual + 1
            end

            resultado = jugada_1.puntos(jugada_2)
            
            if resultado == [1, 0]
                @@puntaje_jugador1 = @@puntaje_jugador1 + 1
            elsif resultado == [0, 1]
                @@puntaje_jugador2 = @@puntaje_jugador2 + 1
            end

            puts "Estrategias:\n P1: #{jugada_1}, P2: #{jugada_2}"
            puts "Resultado de la ronda:\n P1: #{@@puntaje_jugador1}, P2: #{@@puntaje_jugador2}"

            @@rondas = @@rondas + 1

            if @@modo_de_juego == 0 and @@rondas == @@modo_de_juego_limite and @@puntaje_jugador1 > @@puntaje_jugador2
                puts "Gana #{@@nombre_jugador1}"
                break
            elsif @@modo_de_juego == 0 and @@rondas == @@modo_de_juego_limite and @@puntaje_jugador1 < @@puntaje_jugador2
                puts "Gana #{@@nombre_jugador2}"
                break
            elsif @@modo_de_juego == 0 and @@rondas == @@modo_de_juego_limite and @@puntaje_jugador1 == @@puntaje_jugador2
                puts "¡Empate!"
                break
            elsif @@modo_de_juego == 1 and @@puntaje_jugador1 == @@modo_de_juego_limite
                puts "Gana #{@@nombre_jugador1}"
                break
            elsif @@modo_de_juego == 1 and @@puntaje_jugador2 == @@modo_de_juego_limite
                puts "Gana #{@@nombre_jugador2}"
                break
            end
        end
    end

end

# partida = Partida.new

# partida.iniciar_partida()

# jugada1 = Piedra.new
# puts "#{jugada1}"
# jugada2 = Tijera.new
# p jugada1.puntos(jugada2)
# estrategia1 = Manual.new
# # p estrategia1.prox
# estrategia2 = Uniforme.new
# lista = [Piedra, Papel, Tijera]
# p estrategia2.prox(lista)
# estrategia3 = Sesgada.new
# p estrategia3.prox(mapa_de_pesos)