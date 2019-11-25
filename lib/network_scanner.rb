class NetworkScanner
    def self.run
        new.run
    end

    def log_results(networks, location)
        networks.count do |network|
            WirelessNetworkLog.add(network, location)
        end
    end

    def scan
        location = GpsScanner.read

        scan_time, results = Util.time_block do
            Net::IwlistScan.scan
        end

        return if results.length == 0

        db_time, added = Util.time_block do
            log_results(results, location)
        end

        skipped = results.length - added

        puts [
            'Scan:',
            "added=#{added}",
            "skipped=#{skipped}",
            "scan_time=#{scan_time}ms",
            "db_time=#{db_time}ms",
            "lat=#{location.lat}",
            "lng=#{location.lng}",
            "pdop=#{location.pdop}",
            "vdop=#{location.vdop}",
            "hdop=#{location.hdop}",
            "date=#{location.date}",
            "time=#{location.time}",
        ].join(' ')
    end

    def run
        loop do
            scan
            sleep 2
        end
    end
end
