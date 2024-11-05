# main.rb

# Перевірка наявності файлу з класом AppConfigLoader
begin
  require_relative 'app_config_loader'
rescue LoadError => e
  puts "Не вдалося знайти файл 'app_config_loader.rb'. Переконайтеся, що він існує в директорії lib."
  puts "Деталі помилки: #{e.message}"
  exit
end

require 'i18n'
require 'faker'

I18n.config.enforce_available_locales = false

# Перевірка, чи клас AppConfigLoader успішно завантажено
if defined?(AppConfigLoader)
  config_loader = AppConfigLoader.new
  config_loader.load_libs
  puts "Бібліотеки успішно завантажено."
  
  config_data = config_loader.config
  puts "Конфігураційні дані успішно завантажено."
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

# Testing the Item class
item1 = MyApplicationKFC::Item.new(
  title: "Inception",
  year: 2010,
  description: "A skilled thief is given a chance at redemption if he can successfully perform inception.",
  imdb_rating: 8.8,
  image_path: "inception.jpg",
  popularity: 95,
  genres: ["Sci-Fi", "Action"],
  director: "Christopher Nolan",
  stars: ["Leonardo DiCaprio", "Joseph Gordon-Levitt"],
  duration: "148 minutes"
)

puts "Item 1 Details:"
puts item1.info

item2 = MyApplicationKFC::Item.new
puts "\nItem 2 Details (default values):"
puts item2.info

item1.update do |i|
  i.title = "Inception (Updated)"
  i.popularity = 98
end

puts "\nUpdated Item 1 Details:"
puts item1.info

fake_item = MyApplicationKFC::Item.generate_fake
puts "\nFake Item Details:"
puts fake_item.info

if item1 > item2
  puts "\nItem 1 is more popular than Item 2."
else
  puts "\nItem 2 is more popular than Item 1."
end


cart = MyApplicationKFC::Cart.new
cart.generate_test_items(10)
cart.save_to_file
cart.save_to_json
cart.save_to_csv
cart.save_to_yml

# Створення екземпляра класу Configurator
configurator = MyApplicationKFC::Configurator.new

# Налаштування конфігураційних параметрів
configurator.configure(
  run_website_parser: 1,      # Включити розбір сайту
  run_save_to_csv: 1,         # Включити збереження даних в CSV
  run_save_to_yaml: 1,        # Включити збереження даних в YAML
  run_save_to_sqlite: 1       # Включити збереження даних в базі даних SQLite
)

# Виведення поточних конфігурацій
puts configurator.config.inspect

# Отримання доступних методів
puts MyApplicationKFC::Configurator.available_methods.inspect
