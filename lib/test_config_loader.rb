require_relative 'app_config_loader'

config_loader = AppConfigLoader.new

# Завантажуємо бібліотеки
config_loader.load_libs

# Вказуємо шлях до основного конфігураційного файлу та директорії
config_loader.config('config/default_config.yaml', 'config') do |config_data|
  # Використовуємо завантажені дані
  puts "Завантажені конфігураційні дані: #{config_data}"
end

# Виводимо конфігураційні дані у форматі JSON
config_loader.pretty_print_config_data
