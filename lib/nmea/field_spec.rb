module NMEA
    class FieldSpec
        # GPS Minimum Recommended Communication
        GPRMC = %w[
            raw_time
            status_code
            lat_value
            lat_direction
            lng_value
            lng_direction
            knot_speed
            heading
            raw_date
            unknown1
            unknown2
            unknown3
            checksum
        ]

        # GPS Fix Data
        GPGGA = %w[
            raw_time
            lat_value
            lat_direction
            lng_value
            lng_direction
            fix_quality
            number_of_satellites
            horizontal_error
            altitude
            altitude_unit
            geoid_height
            geoid_height_unit
            dgps
            checksum
        ]

        # Date & Time
        GPZDA = %w[
            raw_time
            day
            month
            year
            local_zone
            local_zone_minutes
            checksum
        ]

        # GPS DOP and active satellites
        GPGSA = %w[
            operation_mode
            fix_mode
            sv01
            sv02
            sv03
            sv04
            sv05
            sv06
            sv07
            sv08
            sv09
            sv10
            sv11
            sv12
            pdop
            hdop
            vdop
            checksum
        ]

        def self.get(type)
            const_get(type) if const_defined?(type)
        end
    end
end
