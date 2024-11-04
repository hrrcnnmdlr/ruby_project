require 'sqlite3'

# Вказуємо шлях до вашої бази даних SQLite
db_file = 'catalog.db' # замініть на ваш файл бази даних

begin
  # Підключаємося до бази даних
  db = SQLite3::Database.new(db_file)
  puts "Підключення до бази даних #{db_file} успішне!"

  # Наприклад, можна виконати простий запит
  db.execute("SELECT sqlite_version()") do |row|
    puts "Версія SQLite: #{row[0]}"
  end

rescue SQLite3::Exception => e
  puts "Помилка підключення до бази даних: #{e.message}"
ensure
  db.close if db
end
