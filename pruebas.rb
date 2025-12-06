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

class Uniforme < Estrategia
    def prox(lista)
        randIndex = rand(lista.length - 1)
        jugada = lista[randIndex].new

    end

end