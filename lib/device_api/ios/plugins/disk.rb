module DeviceAPI
  module IOS
    module Plugin
      class Disk
        attr_reader :total_space,
                    :available_space,
                    :used_space,
                    :available,
                    :calendar_usage,
                    :camera_usage,
                    :media_cache_usage,
                    :photo_usage,
                    :web_cache_usage,
                    :voicemail_usage

        def initialize(options = {})
          qualifier = options[:qualifier]
          props     = IDevice.get_props(qualifier, :disk)

          @total_space       = file_size(props[:TotalDataCapacity])
          @available_space   = file_size(props[:TotalDataAvailable])
          @used_space        = file_size(props[:TotalDataCapacity].to_i - props[:TotalDataAvailable].to_i)
          @available         = props[:TotalDataAvailable].to_i * 100 / (props[:TotalDataCapacity].to_i + 2)

          @calendar_usage    = file_size(props[:CalendarUsage])
          @camera_usage      = file_size(props[:CameraUsage])
          @media_cache_usage = file_size(props[:MediaCacheUsage])
          @photo_usage       = file_size(props[:PhotoUsage])
          @web_cache_usage   = file_size(props[:WebAppCacheUsage])
          @voicemail_usage   = file_size(props[:VoicemailUsage])
        end

        private

        def file_size(number)
          {
            'B'  => 1024,
            'KB' => 1024 * 1024,
            'MB' => 1024 * 1024 * 1024,
            'GB' => 1024 * 1024 * 1024 * 1024,
            'TB' => 1024 * 1024 * 1024 * 1024 * 1024
          }.each_pair do |e, s|
            return "#{(number.to_i.to_f / (s / 1024)).round(2)}#{e}" if number.to_i < s
          end
        end
      end
    end
  end
end
