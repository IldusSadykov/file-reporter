require "parallel"
require "./app/models/user.rb"
require "./app/models/session.rb"
require "./app/services/report_generator.rb"
require "concurrent"

class FileReporter
  attr_accessor :file_name, :users, :sessions

  USER_STR = "user".freeze

  def initialize(file_name)
    @file_name = file_name
    @users = Concurrent::Array.new
    @sessions = Concurrent::Array.new
  end

  def execute
    users, sessions = fetch_from_file

    ReportGenerator.new(users, sessions).execute
  end

  private

  # TODO: this method will works fine with small files,
  # if we need process very files the best way will to use database (fill databse from file and then use queries to db)

  def fetch_from_file
    Parallel.each(File.foreach(file_name), in_threads: 8) do |line|
      cols = line.split(",")
      first_col = cols[0]
      cols.shift

      first_col == USER_STR ? users << User.new(*cols) : sessions << Session.new(*cols)
    end

    [users, sessions]
  end
end
