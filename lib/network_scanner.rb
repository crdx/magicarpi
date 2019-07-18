class NetworkScanner
    def initialize
    end

    def time_block
        start = Time.now
        res = yield
        [((Time.now - start) * 1000).round, res]
    end

    def scan
        location = GpsScanner.read

        scan_time, networks = time_block do
            Net::IwlistScan.new
        end

        return if networks.length == 0

        added = 0

        db_time, = time_block do
            networks.each do |network|
                if WirelessNetworkLog.add(network, location)
                    added += 1
                end
            end
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
        Thread.new do
            loop do
                scan
                sleep 1
            end
        end
    end
end
