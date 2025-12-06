class Estrategia
    @@semillaPadre = 42
end

class Jugada 
    def to_s()
        self.class.name
    end
end

class Piedra < Jugada 
    def puntos (contrincante)
        if self.class == contrincante.class
            [0, 0]
        elsif contrincante.class == Papel
            [0, 1]
        elsif contrincante.class == Tijera
            [1,0]
        end
    end
end

class Papel < Jugada 
    def puntos (contrincante)
        if self.class == contrincante.class
            [0, 0]
        elsif contrincante.class == Tijera
            [0, 1]
        elsif contrincante.class == Piedra
            [1,0]
        end
    end
end
class Tijera < Jugada 
    def puntos (contrincante)
        if self.class == contrincante.class
            [0, 0]
        elsif contrincante.class == Piedra
            [0, 1]
        elsif contrincante.class == Papel
            [1,0]
        end
    end
end

MAPA_DE_STR_A_CLASE = {
    "piedra" => Piedra,
    "papel" => Papel,
    "tijera" => Tijera
}

JUGADAS = [Piedra, Papel, Tijera]

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
        randIndex = rand(lista.length - 1)
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
            rndIndex = rand(JUGADAS.length - 1)
            JUGADAS[rndIndex]
        else
            jugada_oponente
        end
        
    end
end

# def Pensar < Estrategia

# end

class Partida
    @@nombre_jugador1 = "Pepe"
    @@estrategia_jugador1 = Uniforme.new
    @@nombre_jugador2 = "Popo"
    @@estrategia_jugador2 = Uniforme.new
    @@modo_de_juego = 0
    @@modo_de_juego_limite = 4
    @@puntaje_jugador1 = 0
    @@puntaje_jugador2 = 0
    @@rondas = 0

    def iniciar_partida()
        loop do
            jugada_1 = @@estrategia_jugador1.prox(JUGADAS)
            jugada_2 = @@estrategia_jugador2.prox(JUGADAS)

            resultado = jugada_1.puntos(jugada_2)

            if resultado == [1, 0]
                @@puntaje_jugador1 = @@puntaje_jugador1 + 1
            elsif resultado == [0, 1]
                @@puntaje_jugador2 = @@puntaje_jugador2 + 1
            end

            puts "Resultado de la ronda:\n P1: #{@@puntaje_jugador1}, P2: #{@@puntaje_jugador2}"

            comando = gets.chomp.downcase
            if comando == "salir"
                break
            end
        end
    end

end

mapa_de_pesos = { Piedra => 100, Papel => 0, Tijera => 0 }

partida = Partida.new

partida.iniciar_partida()

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