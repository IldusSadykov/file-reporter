require "minitest/autorun"
require "minitest/spec"
require_relative "../app/services/parser.rb"

describe Parser do
  describe "#execute" do
    describe "with user data" do
      let(:data) { %w(1 Palmer Katrina 65) }
      let(:fields) { %i(id first_name last_name age) }

      let(:expected_result) do
        {
          id: "1",
          first_name: "Palmer",
          last_name: "Katrina",
          age: "65"
        }
      end

      it "does parse correctly" do
        result = Parser.new(data, fields).execute

        assert_equal expected_result, result
      end
    end

    describe "with session data" do
      let(:data) { %w(1 0 Safari\ 17 12 2016-10-21) }
      let(:fields) { %i(user_id session_id browser time date) }

      let(:expected_result) do
        {
          user_id: "1",
          session_id: "0",
          browser: "Safari 17",
          time: "12",
          date: "2016-10-21"
        }
      end

      it "does parse correctly" do
        result = Parser.new(data, fields).execute

        assert_equal expected_result, result
      end
    end
  end
end
