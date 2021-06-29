require "json"
require "./app/services/user_stats_generator.rb"

class ReportGenerator
  attr_reader :users, :sessions, :report

  def initialize(users, sessions)
    @users = users
    @sessions = sessions
    @report = {}
  end

  def execute
    report[:totalUsers] = users.count
    report[:uniqueBrowsersCount] = uniq_browsers_count
    report[:totalSessions] = sessions.count
    report[:allBrowsers] = all_browsers

    puts "users #{users}"
    UserStatsGenerator.new(report, users, sessions).execute

    puts report
    File.write("result.json", "#{report.to_json}\n")
  end

  private

  def uniq_browsers_count
    uniqueBrowsers = []
    sessions.each do |session|
      browser = session[:browser]
      next if uniqueBrowsers.include?(browser)

      uniqueBrowsers.push(browser)
    end
    uniqueBrowsers.count
  end

  def all_browsers
    sessions
      .map{ |s| s[:browser].upcase }
      .sort
      .uniq
      .join(',')
  end
end
