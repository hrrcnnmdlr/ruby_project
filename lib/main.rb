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

  # Виклик методу load_libs
  config_loader.load_libs
  puts "Бібліотеки успішно завантажено."
else
  puts "Клас AppConfigLoader не завантажено. Перевірте файл 'app_config_loader.rb' на наявність визначення класу."
end
