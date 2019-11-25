class TimeService
    def self.run
        new.run
    end

    def sync
        reading = GpsScanner.read
        date = reading.date
        time = reading.time
        return false if date.nil? || time.nil?
        command = "timedatectl set-time '#{date} #{time}'"
        system command
    end

    def run
        loop do
            sync
            sleep 5
        end
    end
end
