require "json"
require "./app/services/user_stats_generator.rb"

class ReportGenerator
  attr_reader :users, :sessions, :file_name

  def initialize(users, sessions, file_name)
    @users = users
    @file_name = file_name
    @sessions = sessions
  end

  def execute
    report = UserStatsGenerator.new(users, sessions).execute

    File.write("#{ENV['STAGE']}_reports/#{file_name}.json", "#{report.to_json}\n")
  end
end
