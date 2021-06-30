require "date"

class UserStatsGenerator
  attr_reader :report, :users, :sessions, :stats

  def initialize(report, users, sessions)
    @report = report
    @users = users
    @sessions = sessions
    @stats = []
    report[:usersStats] = {}
  end

  def execute
    users.each do |user|
      user.sessions = sessions.select { |session| session.user_id == user.id }
      user_key = [user.first_name, user.last_name].join(" ").to_sym
      report[:usersStats][user_key] = build_stats(user)
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def build_stats(user)
    user_sessions = user.sessions
    total_time = user_sessions.map { |s| s.time.to_i }
    user_browsers = user_sessions.map { |s| s.browser.upcase }
    session_dates = user_sessions.map { |s| Date.parse(s.date) }

    {
      sessionsCount: user.sessions.count,
      totalTime: "#{total_time.sum} min.",
      longestSession: "#{total_time.max} min.",
      browsers: user_browsers.sort.join(", "),
      usedIE: user_browsers.any?(/INTERNET EXPLORER/),
      alwaysUsedChrome: user_browsers.all?(/CHROME/),
      dates: session_dates.sort.reverse.map(&:iso8601)
    }
  end
  # rubocop:enable Metrics/AbcSize
end
