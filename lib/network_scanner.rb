class NetworkScanner
    def initialize
    end

    def self.run
        new.run
    end

    def log_networks(networks, location)
        networks.count do |network|
            WirelessNetworkLog.add(network, location)
        end
    end

    def scan
        location = GpsScanner.read

        scan_time, networks = Util.time_block do
            Net::IwlistScan.new
        end

        return if networks.length == 0

        db_time, added = Util.time_block do
            log_networks(networks, location)
        end

        skipped = networks.length - added

        puts [
            "added=#{added}",
            "skipped=#{skipped}",
            "scan_time=#{scan_time}ms",
            "db_time=#{db_time}ms",
            "lat=#{location.lat}",
            "lng=#{location.lng}",
            "pdop=#{location.pdop}",
            "vdop=#{location.vdop}",
            "hdop=#{location.hdop}",
        ].join(' ')
    end

    def run
        loop do
            scan
            sleep 1
        end
    end
end
