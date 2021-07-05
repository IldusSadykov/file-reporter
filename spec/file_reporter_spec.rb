require "minitest/autorun"
require "minitest/spec"
require "json"
require_relative "../app/services/file_reporter"

describe FileReporter do
  let(:json_path) { "spec/fixtures/json/report.json" }
  let(:expected_result) do
    JSON.parse(File.read(json_path), symbolize_names: true)
  end
  let(:expected_user_stats) do
    expected_result[:usersStats]
  end
  let(:result) { JSON.parse(File.read("final_report_test.json"), symbolize_names: true) }

  before do
      FileReporter.new.execute
  end

  describe "#execute" do
    it "does execute with success expect base field" do
      assert_equal expected_result[:totalUsers], result[:totalUsers]
      assert_equal expected_result[:uniqueBrowsersCount], result[:uniqueBrowsersCount]
      assert_equal expected_result[:totalSessions], result[:totalSessions]
    end

    it "does execute with success expect usersStats field" do
      expected_user_stats.keys.each do |key|
        expected_user_stats[key][:dates].sort!

        assert_equal expected_user_stats[key], result[:usersStats][key]
      end
    end
  end
end
