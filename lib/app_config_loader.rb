class AppConfigLoader
  def initialize
    @system_libs = %w[date] # Список системних бібліотек
    @loaded_files = []       # Масив для відстеження підключених файлів
  end

  def load_libs
    # Підключення системних бібліотек
    @system_libs.each do |lib|
      begin
        require lib
        @loaded_files << lib
        puts "Завантажено системну бібліотеку: #{lib}" # Вивід назви завантаженої бібліотеки
      rescue LoadError => e
        puts "Не вдалося завантажити бібліотеку #{lib}. Деталі помилки: #{e.message}"
      end
    end

    # Підключення локальних бібліотек
    Dir.glob("libs/**/*.rb").each do |file|
      next if @loaded_files.include?(file)

      begin
        require_relative file
        @loaded_files << file
        puts "Завантажено локальну бібліотеку: #{file}" # Вивід назви завантаженої бібліотеки
      rescue LoadError => e
        puts "Не вдалося завантажити локальну бібліотеку #{file}. Деталі помилки: #{e.message}"
      end
    end
  end

  def config
    require 'yaml'
    config_data = YAML.load_file('config/application.yml')
    puts "Конфігураційні дані: #{config_data}" # Вивід завантажених конфігураційних даних
    config_data['logging'] # Повертаємо лише секцію логування
  end

  def pretty_print_config_data
    # Метод для виводу конфігурацій у форматі JSON
    require 'json'
    config_data = config # Виклик методу config для отримання даних
    puts JSON.pretty_generate(config_data)
  end
end
