require "parallel"
require "./app/models/user.rb"
require "./app/models/session.rb"
require "./app/services/report_generator.rb"
require "./app/services/report_joiner.rb"
require "concurrent"

class FileReporter
  USER_STR = "user".freeze

  # TODO: this method will works fine with small files,
  # if we need process very files the best way will to use database (fill databse from file and then use queries to db)

  def execute
    Parallel.each(Dir["#{ENV["STAGE"]}_files/*"], progress: "Progress by files", in_process: 8) do |file|
      users = Concurrent::Array.new
      sessions = Concurrent::Array.new

      Parallel.each(File.foreach(file), in_threads: 8) do |line|
        cols = line.split(",")
        first_col = cols[0]
        cols.shift

        first_col == USER_STR ? users << User.new(*cols) : sessions << Session.new(*cols)
      end

      ReportGenerator.new(users, sessions, file).execute
    end

    ReportJoiner.new(ENV["REPORT_FILE_PATH"]).execute
  end
end
