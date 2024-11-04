require 'yaml'
require 'erb'
require 'json'
require 'pathname'

class AppConfigLoader
  def initialize
    @loaded_libs = [] # Масив для зберігання підключених бібліотек
    load_libs # Завантажуємо бібліотеки при створенні об'єкта
  end

  def config(default_config_path, directory)
    # Завантажуємо основний конфігураційний файл
    @config_data = load_default_config(default_config_path)

    # Завантажуємо додаткові конфігураційні дані з вказаної директорії
    additional_data = load_config(directory)

    # Об'єднуємо основні та додаткові дані
    @config_data.merge!(additional_data) 

    # Виконуємо блок, якщо він передано
    yield @config_data if block_given?

    @config_data
  end

  def pretty_print_config_data
    puts JSON.pretty_generate(@config_data)
  end

  private

  def load_libs
    # Масив системних бібліотек
    system_libs = ['date', 'fileutils'] # Додайте інші системні бібліотеки за потреби

    # Підключаємо системні бібліотеки
    system_libs.each { |lib| require lib }

    # Підключаємо локальні бібліотеки з директорії libs
    Dir.glob(File.join(__dir__, '..', 'libs', '*.rb')).each do |file|
      lib_name = File.basename(file, '.rb')
      unless @loaded_libs.include?(lib_name)
        require_relative file # Використовуємо require_relative для локальних файлів
        @loaded_libs << lib_name # Додаємо ім'я бібліотеки до масиву підключених
        puts "Підключено: #{lib_name}" # Виводимо повідомлення про підключення
      end
    end
  end

  def load_default_config(default_config_path)
    # Завантажуємо основний конфігураційний файл з ERB та YAML
    template = ERB.new(File.read(default_config_path))
    YAML.safe_load(template.result, aliases: true)
  rescue Errno::ENOENT
    puts "Файл не знайдено: #{default_config_path}"
    raise
  end

  def load_config(directory)
    # Завантажуємо всі YAML файли з вказаної директорії
    config_data = {}
    Dir[File.join(directory, '*.yml')].each do |file|
      file_data = YAML.safe_load(File.read(file), aliases: true)
      config_data.merge!(file_data) if file_data # Перевірка на nil перед об'єднанням
    end
    config_data
  end
end
