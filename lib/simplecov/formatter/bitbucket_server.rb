module SimpleCov
  module Formatter
    class BitbucketServer
      VERSION = '1.0.0'

      def initialize(base_uri, sha = ENV['GIT_COMMIT'])
        @base_uri = base_uri
        @sha = sha
      end

      def new
        self
      end

      def format(result)
        upload(coverage_for_bitbucket(result))
      end

      private

      def coverage_for_bitbucket(result)
        { files: files(result) }.to_json
      end

      def files(result)
        puts "Encoding coverage data for #{result.files.size} files"

        result.files.map do |file|
          {
            path: file.project_filename[1..-1],
            coverage: coverage_string(file)
          }
        end
      end

      def coverage_string(file)
        covered_line_numbers = file.covered_lines.map(&:line_number)
        missed_line_numbers = file.missed_lines.map(&:line_number)

        partially_covered_line_numbers, fully_covered_line_numbers =
          covered_line_numbers.partition { |n| file.line_with_missed_branch?(n) }

        covered = fully_covered_line_numbers.join(',')
        partial = partially_covered_line_numbers.join(',')
        uncovered = missed_line_numbers.join(',')

        "C:#{covered};P:#{partial};U:#{uncovered}"
      end

      def upload(coverage)
        puts "Uploading #{coverage.bytesize} bytes of coverage data to #{endpoint}"

        url = endpoint
        req = Net::HTTP::Post.new(
          url.path,
          { 'Content-Type' => 'application/json',
            'User-Agent' => "SimpleCov-BitbucketServer/#{VERSION}" }
        )
        req.body = coverage
        Net::HTTP.start(url.host, url.port, open_timeout: 120, read_timeout: 120, write_timeout: 120) do |http|
          http.request(req)
        end

        puts 'Coverage has been uploaded successfully.'
      rescue Net::OpenTimeout
        puts "#{url.host}:#{url.port} is NOT reachable (OpenTimeout)"
      rescue Net::ReadTimeout
        puts "#{url.host}:#{url.port} is NOT reachable (ReadTimeout)"
      rescue Net::WriteTimeout
        puts "#{url.host}:#{url.port} is NOT reachable (WriteTimeout)"
      end

      def endpoint
        URI.parse("#{@base_uri}/rest/code-coverage/1.0/commits/#{@sha}")
      end
    end
  end
end
