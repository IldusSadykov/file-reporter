require "date"
require "pry"

class UserStatsGenerator
  attr_reader :report, :users, :sessions

  def initialize(report, users, sessions)
    @report = report
    @users = users
    @sessions = sessions
    report[:usersStats] = {}
  end

  def execute
    Parallel.each(users, in_threads: 8) do |user|
      UserStatsWorker.perform(user)
    end
  end
end
