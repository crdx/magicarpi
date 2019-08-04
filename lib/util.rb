class Util
    def self.time_block
        start = Time.now
        res = yield
        [((Time.now - start) * 1000).round, res]
    end

    def self.degrees_minutes_to_decimal_degrees(degrees, minutes)
        (degrees.to_i + minutes.to_f / 60).round(7)
    end
end
