require 'webmock/rspec'
require 'simplecov'
require 'simplecov/formatter/bitbucket_server'

RSpec.describe SimpleCov::Formatter::BitbucketServer do
  let(:formatter) do
    described_class.new(base_url, sha)
  end

  let(:base_url) { 'http://bitbucket.local' }
  let(:sha) { 'abc0123' }
  let(:requested_url) { "#{base_url}/rest/code-coverage/1.0/commits/#{sha}" }
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

    stub_request(:post, requested_url)
      .with(
        headers: {
          'Content-Type' => 'application/json',
          'User-Agent' => 'SimpleCov-BitbucketServer/1.0.0'
        },
        body: '{"files":[{"path":"path/to/file.rb","coverage":"C:1,2;P:3;U:4,5"}]}'
      )
  end

  it 'uploads coverage data to the server' do
    formatter.new.format(result)
  end

  context 'Net::OpenTimeout server connection  error' do
    before do
      stub_request(:post, requested_url).to_raise(Net::OpenTimeout)
    end
    it 'not throw an exception' do
      expect { formatter.new.format(result) }.not_to raise_error
    end
  end

  context 'Net::ReadTimeout server connection  error' do
    before do
      stub_request(:post, requested_url).to_raise(Net::ReadTimeout)
    end
    it 'not throw an exception' do
      expect { formatter.new.format(result) }.not_to raise_error
    end
  end

  context 'Net::WriteTimeout server connection  error' do
    before do
      stub_request(:post, requested_url).to_raise(Net::WriteTimeout)
    end
    it 'not throw an exception' do
      expect { formatter.new.format(result) }.not_to raise_error
    end
  end
end
