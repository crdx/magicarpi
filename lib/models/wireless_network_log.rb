class WirelessNetworkLog < ActiveRecord::Base
    def self.add(network, location)
        return false if seen_recently(network)

        log = create({
            essid: network.essid,
            mac_address: network.mac_address,
            channel: network.channel,
            signal_loss: network.signal_loss,
            auth: network.auth,
            lat: location.lat,
            lng: location.lng,
            hdop: location.hdop,
            vdop: location.vdop,
            pdop: location.pdop,
        })

        WirelessNetworkDump.create({
            wireless_network_log_id: log.id,
            content: network.raw
        })

        return true
    end

    def self.seen_recently(network)
        row = where(essid: network.essid).order('created').last
        return false unless row
        Time.now - row.created < 60 * 10
    end
end
