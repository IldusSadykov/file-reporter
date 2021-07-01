require "json"
require "./app/services/user_stats_generator.rb"

class ReportGenerator
  attr_reader :users, :sessions, :report

  REPORT_FILE_PATH = "result.json".freeze

  def initialize(users, sessions)
    @users = users
    @sessions = sessions
    @report = {
      totalUsers: users.count,
      uniqueBrowsersCount: uniq_browsers_count,
      totalSessions: sessions.count,
      allBrowsers: browsers_list
    }
  end

  def execute
    UserStatsGenerator.new(report, users, sessions).execute

    File.write(REPORT_FILE_PATH, "#{report.to_json}\n")
  end

  private

  def uniq_browsers_count
    unique_browsers = []
    Parallel.each(sessions, in_threads: 8) do |session|
      browser = session.browser
      next if unique_browsers.include?(browser)

      unique_browsers << browser
    end
    unique_browsers.count
  end

  def browsers_list
    sessions
      .map { |s| s.browser.upcase }
      .sort
      .uniq
      .join(",")
  end
end
