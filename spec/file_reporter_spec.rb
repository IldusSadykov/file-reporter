require "minitest/autorun"
require "minitest/spec"
require_relative "../app/services/file_reporter"

describe FileReporter do
  let(:json_path) { "spec/fixtures/json/report.json" }
  let(:expected_result) do
    File.read(json_path)
  end
  let(:data_file_path) { "spec/fixtures/txt/data.txt" }

  describe "#execute" do
    it "does execute with success expect result" do
      FileReporter.new(data_file_path).execute

      assert_equal expected_result, File.read("result.json")
    end
  end
end
