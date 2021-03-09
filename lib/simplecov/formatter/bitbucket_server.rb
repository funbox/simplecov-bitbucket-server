module SimpleCov
  module Formatter
    class BitbucketServer
      VERSION = '0.1.0'

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
        Net::HTTP.post(endpoint, coverage, {
          'Content-Type' => 'application/json',
          'User-Agent' => "SimpleCov-BitbucketServer/#{VERSION}"
        })
      end

      def endpoint
        URI.parse("#{@base_uri}/rest/code-coverage/1.0/commits/#{@sha}")
      end
    end
  end
end
