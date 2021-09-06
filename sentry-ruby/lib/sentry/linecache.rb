module Sentry
  class LineCache
    # Any linecache you provide to Sentry must implement this method.
    # Returns an Array of Strings representing the lines in the source
    # file. The number of lines retrieved is (2 * context) + 1, the middle
    # line should be the line requested by lineno. See specs for more information.
    def get_file_context(filename, lineno, context)
      return nil, nil, nil unless valid_path?(filename)

      lines = Array.new(2 * context + 1) do |i|
        getline(filename, lineno - context + i)
      end
      [lines[0..(context - 1)], lines[context], lines[(context + 1)..-1]]
    end

    private

    def valid_path?(path)
      lines = getline(path, 1)
      !lines.nil?
    end

    def getline(path, line)
      result = nil

      File.open(path, "r") do |f|
        while line > 0
          line -= 1
          result = f.gets
        end
      end

      result
    rescue StandardError
      nil
    end
  end
end
