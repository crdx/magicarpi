class GpsScanner
    def self.read
        @@reading.clone
    end

    def initialize
        @@reading = OpenStruct.new
    end

    def self.run
        new.run
    end

    def run
        read_nmea_sentences do |line|
            sentence = NMEA::Sentence.new(line)
            next if sentence.unparseable?
            process(sentence)
        end
    end

    private

    def read_nmea_sentences(&block)
        loop do
            read_nmea_sentences_til_eof(&block)
        end
    end

    def read_nmea_sentences_til_eof
        file = File.open '/dev/serial0', File::RDWR | Fcntl::O_NOCTTY | Fcntl::O_NDELAY
        file.binmode
        file.sync = true
        file.fcntl Fcntl::F_SETFL, file.fcntl(Fcntl::F_GETFL, 0) & ~Fcntl::O_NONBLOCK

        begin
            while line = file.readline
                if line.valid_encoding? && line.start_with?('$')
                    yield line[1..-1]
                end
            end
        rescue EOFError => e
        end
    end

    def merge_components(value, direction)
        if direction == 'N'
            parts = value.match(/(\d{2})([\d.]+)/)
        else
            parts = value.match(/(\d{3})([\d.]+)/)
        end

        if parts
            direction + Util.degrees_minutes_to_decimal_degrees(*parts[1..-1]).to_s
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
