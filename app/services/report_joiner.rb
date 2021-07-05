require "json"
require "./app/services/user_stats_generator.rb"

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
    Parallel.each(Dir["#{ENV["STAGE"]}_reports/#{ENV["STAGE"]}_files/*"], progress: "Progress by json files", in_threads: 8) do |file|
      result = JSON.parse(File.read(file), symbolize_names: true)
      users = result[:users]
      sessions = result[:sessions]
      report[:totalUsers] += users.keys.count

      users.each do |id, user|
        report[:usersStats][id] = {} if report[:usersStats][id].nil?
        target_user = report[:usersStats][id]
        target_user[:fullName] = user[:fullName]
      end

      sessions.each do |id, session|
        key = id
        report[:usersStats][key] = {} unless report[:usersStats].key?(key)
        target_user = report[:usersStats][key]
        target_user[:sessionsCount] = 0 unless target_user.key?(:sessionsCount)
        target_user[:sessionsCount] += session[:count]
        report[:totalSessions] += session[:count]

        target_user[:totalTime] = "0 min." unless target_user.key?(:totalTime)
        total_time = target_user[:totalTime].split(" ")[0].to_i + session[:totalTime].to_i
        target_user[:totalTime] = "#{total_time} min."

        target_user[:longestSession] = "0 min." unless target_user.key?(:longestSession)
        total_session = [target_user[:longestSession].split(" ")[0].to_i, session[:longestSession]].flatten.max
        target_user[:longestSession] = "#{total_session} min."

        target_user[:browsers] = "" unless target_user.key?(:browsers)
        browsers = target_user[:browsers].split(", ") + session[:browsers]
        target_user[:browsers] = browsers.sort.join(", ")
        report[:allBrowsers] = (report[:allBrowsers].split(",") + session[:browsers]).uniq.join(",")

        target_user[:usedIE] = false unless target_user.key?(:usedIE)
        target_user[:usedIE] = target_user[:usedIE] || session[:usedIE]

        target_user[:alwaysUsedChrome] = false unless target_user.key?(:alwaysUsedChrome)
        target_user[:alwaysUsedChrome] = target_user[:alwaysUsedChrome] && session[:alwaysUsedChrome]

        target_user[:dates] = [] unless target_user.key?(:dates)
        target_user[:dates] += session[:dates]
        target_user[:dates].sort!
      end
    end

    new_users_stats = {}
    report[:usersStats].each do |id, user|
      full_name = user.delete(:fullName)
      new_users_stats[full_name] = user
    end
    report.delete(:usersStats)
    report[:usersStats] = new_users_stats
    report[:uniqueBrowsersCount] = report[:allBrowsers].split(",").uniq.count

    File.write(file_name, "#{report.to_json}\n")
  end
end
