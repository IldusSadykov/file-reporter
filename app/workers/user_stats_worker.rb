class UserStatsWorker
  include Sidekiq::Worker

  REPORT_FILE_PATH = "user_stats.json".freeze

  def perform(name, count)
    build_sessions(user)
    user_key = [user.first_name, user.last_name].join(" ").to_sym
    report = {}
    report[user_key] = build_stat(user)
    File.write(REPORT_FILE_PATH, "#{report.to_json}\n")
    file = File.open(REPORT_FILE_PATH, "a")
    file.write(report.to_json)
    file.close
  end

  private

  def build_sessions(user)
    user.sessions ||= []

    Parallel.each(sessions, in_threads: 8) do |session|
      next unless session.user_id == user.id

      user.sessions << session
    end

    puts "finished build session for user.id= #{user.id}"
  end

  # rubocop:disable Metrics/AbcSize
  def build_stat(user)
    user_sessions = user.sessions
    total_time = []
    user_browsers = []
    session_dates = []
    used_ie = false
    only_chrome = true

    Parallel.each(user_sessions, in_threads: 8) do |session|
      browser = session.browser.upcase
      total_time << session.time.to_i
      user_browsers << browser
      session_dates << Date.parse(session.date)
      used_ie = true if browser.match(/INTERNET EXPLORER/)
      only_chrome = false unless browser.match(/CHROME/)
    end

    {
      sessionsCount: user.sessions.count,
      totalTime: "#{total_time.sum} min.",
      longestSession: "#{total_time.max} min.",
      browsers: user_browsers.sort.join(", "),
      usedIE: used_ie,
      alwaysUsedChrome: only_chrome,
      dates: session_dates.sort.reverse.map(&:iso8601)
    }
  end
  # rubocop:enable Metrics/AbcSize
end
