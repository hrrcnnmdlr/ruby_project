require 'mechanize'
require 'yaml'  # Потрібно для роботи з YAML-файлом
require_relative 'logger_manager'

# Ініціалізуємо логування (шлях до файлу конфігурації)
MyApplicationKFC::LoggerManager.initialize_logger('config.yml')

# Запуск парсера
parser = MyApplicationKFC::SimpleWebsiteParser.new('config.yml')
parser.start_parse

puts "Парсинг завершено. Перевірте збережені дані та логи."

