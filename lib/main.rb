require_relative 'app_config_loader'

config_loader = AppConfigLoader.new

# Вказуємо абсолютний шлях до основного конфігураційного файлу
default_config_path = File.join(__dir__, '..', 'config', 'default_config.yaml') 
# Вказуємо абсолютний шлях до директорії з YAML файлами
config_directory = File.join(__dir__, '..', 'config') 

# Виконуємо завантаження конфігураційних даних
config_loader.config(default_config_path, config_directory) do |config_data|
  # Використовуємо завантажені дані
  puts "Завантажені конфігураційні дані: #{config_data}"
end

# Виводимо конфігураційні дані у форматі JSON
config_loader.pretty_print_config_data
