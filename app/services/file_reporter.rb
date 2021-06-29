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

require "./app/services/report_generator.rb"
require "./app/services/parser.rb"

class FileReporter
  attr_reader :file_name

  USER_STR = "user"
  SESSION_STR = "session"

  USER_FIELDS = %i(id first_name last_name age)
  SESSION_FIELDS = %i(user_id session_id browser time date)

  def initialize(file_name)
    @file_name = file_name
  end

  def execute
    users = []
    sessions = []

    File.foreach(file_name) do |line|
      cols = line.split(',')
      if cols[0] == USER_STR
        cols.shift
        user = Parser.new(cols, USER_FIELDS).execute
        users.push(user)
      end
      if cols[0] == SESSION_STR
        cols.shift
        session = Parser.new(cols, SESSION_FIELDS).execute
        sessions.push(session)
      end
    end

    puts "users #{users}"
    ReportGenerator.new(users, sessions).execute
  end
end
