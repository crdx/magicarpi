module Net
    class IwlistScan
        include Enumerable

        def self.scan
            new(`iwlist wlan0 scan`.lines.map(&:strip).reject(&:empty?))
        end

        def initialize(lines)
            @lines = lines
            @networks = to_enum(:parse_each).to_a
        end

        def length
            count
        end

        def each(&block)
            @networks.each(&block)
        end

        private

        def parse_each
            cur = nil
            @lines.each do |line|
                if line =~ /Cell \d+/
                    yield cur if cur && cur = IwlistNetwork.parse(cur)
                    cur = []
                end
                cur << line if cur
            end
            yield cur if cur && cur = IwlistNetwork.parse(cur)
        end
    end
end
