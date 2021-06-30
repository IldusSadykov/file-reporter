# Отчёт в json
#   - Сколько всего юзеров +
#   - Сколько всего уникальных браузеров +
#   - Сколько всего сессий +
#   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
#
#   - По каждому пользователю
#     - сколько всего сессий +
#     - сколько всего времени +
#     - самая длинная сессия +
#     - браузеры через запятую +
#     - Хоть раз использовал IE? +
#     - Всегда использовал только Хром? +
#     - даты сессий в порядке убывания через запятую +

require "./app/models/user.rb"
require "./app/models/session.rb"
require "./app/services/report_generator.rb"

class FileReporter
  attr_reader :file_name

  USER_STR = "user"
  SESSION_STR = "session"

  def initialize(file_name)
    @file_name = file_name
  end

  def execute
    users, sessions = fetch_from_file

    ReportGenerator.new(users, sessions).execute
  end

  private

  # TODO: this method will works fine with small files,
  # if we need process very files the best way will to use database (fill databse from file and then use queries to db)

  def fetch_from_file
    users = []
    sessions = []

    File.foreach(file_name) do |line|
      cols = line.split(',')
      if cols[0] == USER_STR
        cols.shift
        user = User.new(*cols)
        users.push(user)
      end
      if cols[0] == SESSION_STR
        cols.shift
        session = Session.new(*cols)
        sessions.push(session)
      end
    end

    [users, sessions]
  end
end
