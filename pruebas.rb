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
        if (self.class == contrincante.class)
            [0, 0]
        elsif (contrincante.class == Papel)
            [0, 1]
        elsif (contrincante.class == Tijera)
            [1,0]
    end
end

class Papel < Jugada 
    def puntos (contrincante)
        if (self.class == contrincante.class)
            [0, 0]
        elsif (contrincante.class == Tijera)
            [0, 1]
        elsif (contrincante.class == Piedra)
            [1,0]
    end
end
class Tijera < Jugada 
    def puntos (contrincante)
        if (self.class == contrincante.class)
            [0, 0]
        elsif (contrincante.class == Piedra)
            [0, 1]
        elsif (contrincante.class == Papel)
            [1,0]
    end
end

MAPA_DE_STR_A_CLASE = {
    "piedra" => Piedra,
    "papel" => Papel,
    "tijera" => Tijera
}

class Manual < Estrategia
    def prox()
        print "Inserte la próxima jugada: "
        jugada_str = gets.chomp.downcase
        if (MAPA_DE_STR_A_CLASE.key?(jugada_str))
            jugada = MAPA_DE_STR_A_CLASE[jugada_str].new
    end
end

class Uniforme < Estrategia
    def prox(lista)
        randIndex = rand(lista.length - 1)
        jugada = lista[randIndex].new

    end

end

