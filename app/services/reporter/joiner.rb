require "json"

class ReportJoiner
  attr_reader :report, :file_name

  def initialize(file_name)
    @file_name = file_name
    @report = Concurrent::Hash[
      totalUsers: 0,
      uniqueBrowsersCount: 0,
      totalSessions: 0,
      allBrowsers: "",
      usersStats: {}
    ]
  end

  def execute
    build
    update_report

    File.write(file_name, "#{report.to_json}\n")
  end

  private

  def build
    Parallel.each(
      Dir["#{ENV['STAGE']}_reports/#{ENV['STAGE']}_files/*"],
      progress: "Progress by json files",
      in_threads: 8
    ) do |file|
      result = JSON.parse(File.read(file), symbolize_names: true)

      users = result[:users]
      report[:totalUsers] += users.keys.count

      build_users(users)
      build_sessions(result[:sessions])
    end
  end

  # rubocop:disable Metrics/AbcSize
  def update_report
    new_users_stats = {}
    report[:usersStats].each { |_id, user| new_users_stats[user.delete(:fullName).to_sym] = user }
    report.delete(:usersStats)
    report[:usersStats] = new_users_stats
    report[:uniqueBrowsersCount] = report[:allBrowsers].split(",").uniq.count
  end
  # rubocop:enable Metrics/AbcSize

  def build_users(users)
    users.each do |id, user|
      report[:usersStats][id] = report[:usersStats].fetch(id, {})
      report[:usersStats][id][:fullName] = user[:fullName]
    end
  end

  def build_sessions(sessions)
    sessions.each do |id, session|
      report[:totalSessions] += session[:count]
      report[:allBrowsers] = (report[:allBrowsers].split(",") + session[:browsers]).uniq.join(",")

      build_stat_item(id, session)
    end
  end

  def fill_with_defaults(user)
    {
      totalTime: user.fetch(:totalTime, "0 min."),
      sessionsCount: user.fetch(:sessionsCount, 0),
      longestSession: user.fetch(:longestSession, "0 min."),
      browsers: user.fetch(:browsers, ""),
      usedIE: user.fetch(:usedIE, false),
      alwaysUsedChrome: user.fetch(:alwaysUsedChrome, false),
      dates: user.fetch(:dates, []),
      fullName: user.fetch(:fullName, "")
    }
  end

  # rubocop:disable Metrics/AbcSize
  def build_stat_item(id, session)
    user_stat = fill_with_defaults(report[:usersStats].fetch(id, {}))
    total_time = user_stat[:totalTime].split(" ")[0].to_i + session[:totalTime].to_i
    total_session = [user_stat[:longestSession].split(" ")[0].to_i, session[:longestSession]].flatten.max
    browsers = user_stat[:browsers].split(", ") + session[:browsers]

    report[:usersStats][id] = {
      totalTime: "#{total_time} min.",
      sessionsCount: user_stat[:sessionsCount] + session[:count],
      longestSession: "#{total_session} min.",
      browsers: browsers.sort.join(", "),
      usedIE: user_stat[:usedIE] || session[:usedIE],
      alwaysUsedChrome: user_stat[:alwaysUsedChrome] && session[:alwaysUsedChrome],
      dates: (user_stat[:dates] + session[:dates]).sort,
      fullName: user_stat[:fullName]
    }
  end
  # rubocop:enable Metrics/AbcSize
end
