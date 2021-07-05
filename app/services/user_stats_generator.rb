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
    users.each do |user|
      report[:users][user.id.to_sym] = {} if report[:users][user.id.to_sym].nil?
      report[:users][user.id.to_sym] = {
        fullName: "#{user.first_name} #{user.last_name}",
        age: user.age
      }
    end

    sessions.each do |session|
      build_session(session)
    end

    report
  end

  private

  # rubocop:disable Metrics/AbcSize
  def build_session(session)
    used_ie = false
    only_chrome = true
    session_date = 0

    browser = session.browser ? session.browser.upcase : ""

    if session.date
      y, m, d = session.date.split "-"
      session_date = Date.parse(session.date) if Date.valid_date?(y.to_i, m.to_i, d.to_i)
    end

    used_ie = true if browser.match(/INTERNET EXPLORER/)
    only_chrome = false unless browser.match(/CHROME/)

    user_id = session.user_id.to_s.to_sym
    report[:sessions][user_id] = {} unless report[:sessions].key?(user_id)
    target_session = report[:sessions][user_id]

    target_session[:alwaysUsedChrome] = only_chrome
    target_session[:totalTime] = 0 unless target_session.key?(:totalTime)
    target_session[:totalTime] += session.time.to_i
    target_session[:longestSession] = [] unless target_session.key?(:longestSession)
    target_session[:longestSession] << session.time.to_i
    target_session[:browsers] = [] unless target_session.key?(:browsers)
    target_session[:browsers] << browser
    target_session[:dates] = [] unless target_session.key?(:dates)
    target_session[:dates] << session_date.iso8601
    target_session[:usedIE] = false unless target_session.key?(:usedIE)
    target_session[:usedIE] = used_ie
    target_session[:count] = 0 unless target_session.key?(:count)
    target_session[:count] += 1
  end
  # rubocop:enable Metrics/AbcSize
end
