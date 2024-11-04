# lib/my_application_name/logger_manager.rb

require 'yaml'
require 'logger'
require 'fileutils'

module MyApplicationKFC
  class LoggerManager
    class << self
      attr_reader :logger, :error_logger

      def initialize_logger(config_file)
        config = load_config(config_file)

        log_directory = config['directory']
        log_level = config['level'] || 'INFO'
        log_files = config['files'] || {}

        # Перевірка наявності log_directory
        if log_directory.nil? || log_directory.empty?
          puts "Помилка: Директорія для логів не вказана в конфігураційних даних."
          exit
        end

        # Створення директорії для логів, якщо вона не існує
        FileUtils.mkdir_p(log_directory)

        # Ініціалізація основного логера
        application_log_file = log_files['application_log'] || 'application.log'
        @logger = Logger.new(File.join(log_directory, application_log_file))
        @logger.level = Logger.const_get(log_level)

        # Ініціалізація логера помилок
        error_log_file = log_files['error_log'] || 'error.log'
        @error_logger = Logger.new(File.join(log_directory, error_log_file))
        @error_logger.level = Logger::ERROR
      end

      def load_config(file_path)
        config = YAML.load_file(file_path)
        puts "Завантажена конфігурація: #{config.inspect}"  # Додано для відлагодження
        config
      rescue Errno::ENOENT => e
        puts "Не вдалося знайти конфігураційний файл: #{file_path}. Помилка: #{e.message}"
        exit
      rescue Psych::SyntaxError => e
        puts "Помилка в синтаксисі YAML: #{e.message}"
        exit
      end
      

      def log_processed_file(message)
        @logger.info(message) if @logger
      end

      def log_error(message)
        @error_logger.error(message) if @error_logger
      end
    end
  end
end
