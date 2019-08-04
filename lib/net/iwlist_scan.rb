module Net
    class IwlistScan
        include Enumerable

        def initialize
            scan
        end

        def scan
            @lines = `iwlist wlan0 scan`.lines.map(&:strip).reject(&:empty?)
            @networks = to_enum(:each_network).to_a.reject do |network|
                network.essid.empty?
            end
        end

        def length
            @networks.length
        end

        def each
            @networks.each
        end

        def each_network
            cur = nil
            @lines.each do |line|
                if line =~ /Cell \d+/
                    yield IwlistNetwork.new(cur) if cur
                    cur = []
                end
                cur << line if cur
            end
            yield IwlistNetwork.new(cur)
        end
    end
end
