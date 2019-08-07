class IwlistNetwork
    attr_reader :raw

    def initialize(props, lines)
        @props = props
        @raw = lines.join("\n")
    end

    def method_missing(name, *args)
        @props.send(name)
    end

    def self.parse(lines)
        props = OpenStruct.new.tap do |props|
            lines.each do |line|
                case line
                when /Cell (\d+) - Address: (.*)/    then props.cell = $1.to_i
                                                          props.mac_address = $2
                when /Channel:(\d+)/                 then props.channel = $1.to_i
                when /Frequency:(.*) \(/             then props.frequency = $1
                when /Signal level=(.*)/             then props.signal_loss = $1
                when /ESSID:"(.*)"/                  then props.essid = $1
                when /Last beacon: (.*)/             then props.last_beacon = $1
                when /Authentication Suites.*: (.*)/ then props.auth = $1
                end
            end
        end

        if props.essid.empty?
            return nil
        end

        IwlistNetwork.new(props, lines)
    end
end
