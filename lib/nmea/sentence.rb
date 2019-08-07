module NMEA
    class Sentence
        attr_reader :code
        attr_reader :data

        def initialize(code, data)
            @code = code
            @data = data
        end

        def self.parse(sentence)
            code, *args = sentence.split(/[,*]/)
            fields = FieldSpec.get(code)

            return if fields.nil?

            data = Struct.new(*fields.map(&:to_sym)).new.tap do |structure|
                fields.map.with_index do |field, i|
                    structure[field] = args[i]
                end
            end

            new(code.to_sym, data)
        end
    end
end

