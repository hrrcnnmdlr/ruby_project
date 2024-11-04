require 'yaml'
require 'logger'
require 'fileutils'
require 'faker'

# Set Faker's locale to English
Faker::Config.locale = 'en'

module MyApplicationKFC
  class LoggerManager
    class << self
      attr_reader :logger, :error_logger

      def initialize_logger(config_file)
        config = load_config(config_file)
      
        # Звернення до конфігураційних даних з урахуванням структури
        log_directory = config.dig('logging', 'directory')
        log_level = config.dig('logging', 'level') || 'INFO'
        log_files = config.dig('logging', 'files') || {}
      
        # Перевірка наявності директорії
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
      
        puts "Логування успішно налаштовано."
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



  class Item
    attr_accessor :title, :year, :description, :imdb_rating, :image_path, :popularity, :genres, :director, :stars, :duration

    def initialize(attributes = {}, &block)
      @title = attributes[:title] || "Default Title"
      @year = attributes[:year] || 2000
      @description = attributes[:description] || "Default Description"
      @imdb_rating = attributes[:imdb_rating] || 0.0
      @image_path = attributes[:image_path] || "default_image_path.jpg"
      @popularity = attributes[:popularity] || 0
      @genres = attributes[:genres] || []
      @director = attributes[:director] || "Unknown Director"
      @stars = attributes[:stars] || []
      @duration = attributes[:duration] || "N/A"

      LoggerManager.log_processed_file("Initialized Item: #{@title}")

      yield self if block_given?
    end

    def to_s
      attributes = instance_variables.map { |var| "#{var.to_s.delete('@')}: #{instance_variable_get(var)}" }
      attributes.join(", ")
    end

    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete('@')] = instance_variable_get(var)
      end
    end

    def inspect
      to_s
    end

    def update(&block)
      yield self if block_given?
    end

    alias_method :info, :to_s

    def self.generate_fake
      new(
        title: Faker::Movie.title,
        year: Faker::Number.between(from: 1900, to: 2024),
        description: Faker::Movie.quote,
        imdb_rating: Faker::Number.decimal(l_digits: 1, r_digits: 1),
        image_path: Faker::LoremPixel.image(size: "300x300", is_gray: false),
        popularity: Faker::Number.between(from: 1, to: 100),
        genres: [Faker::Book.genre, Faker::Book.genre],
        director: Faker::Name.name,
        stars: [Faker::Name.name, Faker::Name.name],
        duration: "#{Faker::Number.between(from: 60, to: 180)} minutes"
      )
    end

    include Comparable

    def <=>(other)
      @popularity <=> other.popularity
    end
  end
end
