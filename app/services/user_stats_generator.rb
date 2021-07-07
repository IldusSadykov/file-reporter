require "date"
require "pry"

class UserStatsGenerator
  attr_reader :report, :users, :sessions

  def initialize(users, sessions)
    @users = users
    @sessions = sessions
    @report = {
      users: {},
      sessions: {}
    }
  end

  def execute
    build_users

    sessions.each do |session|
      build_session(session)
    end

    report
  end

  private

  def build_users
    users.each do |user|
      report[:users][user.id.to_sym] = {
        fullName: "#{user.first_name} #{user.last_name}",
        age: user.age
      }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def build_session(session)
    user_id = session.user_id.to_s.to_sym
    current_session = report[:sessions].fetch(user_id, {})
    total_time = current_session.fetch(:totalTime, 0)
    longest_session = current_session.fetch(:longestSession, [])
    browser = session.browser ? session.browser.upcase : ""
    browsers = current_session.fetch(:browsers, [])
    dates = current_session.fetch(:dates, [])
    current_used_ie = current_session.fetch(:usedIE, false) || false
    current_only_chrome = current_session.fetch(:alwaysUsedChrome, false)
    count = current_session.fetch(:count, 0)

    used_ie = browser.match(/INTERNET EXPLORER/) ? true : false
    only_chrome = false unless browser.match(/CHROME/)

    report[:sessions][user_id] = {
      alwaysUsedChrome: current_only_chrome && only_chrome,
      totalTime: total_time + session.time.to_i,
      longestSession: longest_session.push(session.time.to_i),
      browsers: browsers.push(browser),
      dates: dates.push(session_date(session)),
      usedIE: (current_used_ie || used_ie),
      count: count + 1
    }
  end
  # rubocop:enable Metrics/AbcSize

  def session_date(session)
    return 0 unless session.date

    y, m, d = session.date.split "-"
    date = Date.parse(session.date) if Date.valid_date?(y.to_i, m.to_i, d.to_i)
    date.iso8601
  end
end
