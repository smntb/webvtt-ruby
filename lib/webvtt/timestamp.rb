module WebVTT
  class Timestamp
    def self.parse_seconds( timestamp )
      if mres = timestamp.match(/\A([0-9]{2}):([0-9]{2}):([0-9]{2}\.[0-9]{3})\z/)
        sec = mres[3].to_f # seconds and subseconds
        sec += mres[2].to_f * 60 # minutes
        sec += mres[1].to_f * 60 * 60 # hours
      elsif mres = timestamp.match(/\A([0-9]{2}):([0-9]{2}\.[0-9]{3})\z/)
        sec = mres[2].to_f # seconds and subseconds
        sec += mres[1].to_f * 60 # minutes
      else
        raise ArgumentError.new("Invalid WebVTT timestamp format: #{timestamp.inspect}")
      end

      return sec
    end

    def initialize( time )
      if time.is_a? Numeric
        @timestamp = time
      elsif time.is_a? String
        @timestamp = Timestamp.parse_seconds( time )
      else
        raise ArgumentError.new("time not numeric nor a string")
      end
    end

    def to_s
      hms = [60,60].reduce( [ @timestamp ] ) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
      hms << (@timestamp.divmod(1).last * 1000).round

      sprintf("%02d:%02d:%02d.%03d", *hms)
    end

    def to_f
      @timestamp.to_f
    end

    def +(other)
      Timestamp.new self.to_f + other.to_f
    end

  end
end
