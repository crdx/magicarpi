class GpsScanner
    def self.run(port)
        new(port).run
    end

    def self.read
        @@reading.clone
    end

    def initialize(port)
        @@reading = OpenStruct.new
        @port = port
    end

    def run
        read_nmea_sentences do |line|
            sentence = NMEA::Sentence.parse(line)
            next if sentence.nil?
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
        # Make *absolutely* sure we don't prevent anyone else from accessing
        # the serial port. No one else would on our single-user system, but it's
        # good manners nonetheless.
        file = File.open '/dev/' + @port, File::RDWR | Fcntl::O_NOCTTY | Fcntl::O_NDELAY
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
        end
    end

    def parse_six_digits(str)
         str =~ /(\d\d)(\d\d)(\d\d)/
         [$1, $2, $3]
     end

    # 222517.000
    def parse_time(str)
        parse_six_digits(str) * ':'
    end

    # 251119
    def parse_date(str)
        parse_six_digits(str).reverse * '-'
    end

    def process(sentence)
        @@reading = @@reading.clone.tap do |reading|
            return unless [:GPRMC, :GPGSA].include?(sentence.code)

            case sentence.code
            when :GPRMC
                reading.lat = merge_components(sentence.data.lat_value, sentence.data.lat_direction)
                reading.lng = merge_components(sentence.data.lng_value, sentence.data.lng_direction)
                reading.time = parse_time(sentence.data.raw_time)
                reading.date = parse_date(sentence.data.raw_date)
            when :GPGSA
                reading.pdop = sentence.data.pdop
                reading.hdop = sentence.data.hdop
                reading.vdop = sentence.data.vdop
            end
        end
    end
end
