require 'simplecov'
require 'simplecov/formatter/bitbucket_server'
require 'webmock/rspec'

RSpec.describe SimpleCov::Formatter::BitbucketServer do
  let(:formatter) do
    described_class.new('http://bitbucket.local', 'abc0123')
  end

  let(:result) { instance_double(SimpleCov::Result, files: [file]) }

  let(:file) do
    instance_double(SimpleCov::SourceFile,
                    project_filename: '/path/to/file.rb',
                    covered_lines: [line1, line2, line3],
                    missed_lines: [line4, line5])
  end

  let(:line1) { instance_double(SimpleCov::SourceFile::Line, line_number: 1) } # C
  let(:line2) { instance_double(SimpleCov::SourceFile::Line, line_number: 2) } # C
  let(:line3) { instance_double(SimpleCov::SourceFile::Line, line_number: 3) } # P
  let(:line4) { instance_double(SimpleCov::SourceFile::Line, line_number: 4) } # U
  let(:line5) { instance_double(SimpleCov::SourceFile::Line, line_number: 5) } # U

  before do
    allow(file).to receive(:line_with_missed_branch?) { |n| n == 3 }

    stub_request(:post, 'http://bitbucket.local/rest/code-coverage/1.0/commits/abc0123')
      .with(
        headers: {
          'Content-Type' => 'application/json',
          'User-Agent' => 'SimpleCov-BitbucketServer/0.1.0'
        },
        body: '{"files":[{"path":"path/to/file.rb","coverage":"C:1,2;P:3;U:4,5"}]}'
      )
  end

  it 'uploads coverage data to the server' do
    formatter.new.format(result)
  end
end
