class GpsScanner
    def self.read
        @@reading.clone
    end

    def initialize
        @@reading = OpenStruct.new
    end

    def run
        Thread.new do
            read_nmea_sentences do |line|
                sentence = NMEA::Sentence.new(line)
                next if sentence.unparseable?
                process(sentence)
            end
        end
    end

    private

    def read_nmea_sentences
        File.foreach('/dev/serial0') do |line|
            if line.valid_encoding? && line.start_with?('$')
                yield line[1..-1]
            end
        end
    end

    def degrees_minutes_to_decimal_degrees(degrees, minutes)
        (degrees.to_i + minutes.to_f / 60).round(7)
    end

    def merge_components(value, direction)
        if direction == 'N'
            parts = value.match(/(\d{2})([\d.]+)/)
        else
            parts = value.match(/(\d{3})([\d.]+)/)
        end

        if parts
            direction + degrees_minutes_to_decimal_degrees(*parts[1..-1]).to_s
        else
            nil
        end
    end

    def process(sentence)
        @@reading = @@reading.clone.tap do |reading|
            return if ![:GPRMC, :GPGSA].include?(sentence.code)

            case sentence.code
            when :GPRMC
                reading.lat = merge_components(sentence.data.lat_value, sentence.data.lat_direction)
                reading.lng = merge_components(sentence.data.lng_value, sentence.data.lng_direction)
            when :GPGSA
                reading.pdop = sentence.data.pdop
                reading.hdop = sentence.data.hdop
                reading.vdop = sentence.data.vdop
            end
        end
    end
end
