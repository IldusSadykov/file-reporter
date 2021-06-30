require "./app/models/user.rb"
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
    fill_stats
    collect_user_stats
  end

  private

  def fill_stats
    users.each do |user|
      attributes = user
      user_sessions = sessions.select { |session| session[:user_id] == user[:id] }
      user_object = User.new(attributes, user_sessions)
      stats.push(user_object)
    end
  end

  def build_stats(user)
    user_sessions = user.sessions
    total_time = user_sessions.map{ |s| s[:time].to_i }
    user_browsers = user_sessions.map{ |s| s[:browser].upcase }
    session_dates = user_sessions.map{ |s| Date.parse(s[:date]) }

    {
      sessionsCount: user.sessions.count,
      totalTime: "#{ total_time.sum } min.",
      longestSession: "#{ total_time.max } min.",
      browsers: user_browsers.sort.join(', '),
      usedIE: user_browsers.any?(/INTERNET EXPLORER/),
      alwaysUsedChrome: user_browsers.all?(/CHROME/),
      dates: session_dates.sort.reverse.map { |d| d.iso8601 }
    }
  end

  def collect_user_stats
    stats.each do |user|
      user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"
      report[:usersStats][user_key.to_sym] = build_stats(user)
    end
  end
end
