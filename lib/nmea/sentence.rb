module NMEA
    class Sentence
        attr_reader :data

        def initialize(sentence)
            parse(sentence.strip)
        end

        def code
            @code
        end

        def unparseable?
            @data.nil?
        end

        def parse(sentence)
            code, *args = sentence.split(/[,*]/)
            fields = FieldSpec.get(code)

            return if fields.nil?

            @code = code.to_sym

            @data = Struct.new(*fields.map(&:to_sym)).new.tap do |structure|
                fields.map.with_index do |field, i|
                    structure[field] = args[i]
                end
            end
        end
    end
end

