# main.rb

# Перевірка наявності файлу з класом AppConfigLoader
begin
  require_relative 'app_config_loader'
rescue LoadError => e
  puts "Не вдалося знайти файл 'app_config_loader.rb'. Переконайтеся, що він існує в директорії lib."
  puts "Деталі помилки: #{e.message}"
  exit
end

# Перевірка, чи клас AppConfigLoader успішно завантажено
if defined?(AppConfigLoader)
  # Створення екземпляра класу AppConfigLoader
  config_loader = AppConfigLoader.new

  # Виклик методу load_libs для автоматичного підключення бібліотек
  config_loader.load_libs
  puts "Бібліотеки успішно завантажено."

  # Завантаження конфігурацій
  config_data = config_loader.config
  puts "Конфігураційні дані успішно завантажено."

  # Перевірка завантаження конфігурацій
  config_loader.pretty_print_config_data
else
  puts "Клас AppConfigLoader не завантажено. Перевірте файл 'app_config_loader.rb' на наявність визначення класу."
  exit
end

# Налаштування логування
begin
  require_relative 'libs/logger_manager'
  MyApplicationKFC::LoggerManager.initialize_logger('config/logging.yaml')
rescue LoadError => e
  puts "Не вдалося знайти файл 'logger_manager.rb'. Переконайтеся, що він існує в директорії lib."
  puts "Деталі помилки: #{e.message}"
  exit
end

# Перевірка логування
MyApplicationKFC::LoggerManager.log_processed_file('Файл успішно оброблено.')
MyApplicationKFC::LoggerManager.log_error('Виникла помилка під час обробки файлу.')

puts "Логування налаштовано. Події було записано у лог."