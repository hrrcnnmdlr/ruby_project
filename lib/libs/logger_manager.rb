require 'yaml'
require 'logger'
require 'fileutils'
require 'faker'
require 'csv'
require_relative 'item_container'
require 'mechanize'
require_relative 'logger_manager'


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
        image_path: "/path/to/image.jpg", # Вкажи шлях до конкретного фото
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

  class Cart
    include ItemContainer
    include Enumerable

    attr_accessor :items

    def initialize
      @items = []
      LoggerManager.log_processed_file("Cart initialized")
      Dir.mkdir('output') unless Dir.exist?('output') # Створення папки output, якщо вона не існує
    end

    def each(&block)
      @items.each(&block)
    end

    # Збереження інформації у файли
    def save_to_file(filename = 'output/items.txt')
      File.open(filename, 'w') do |file|
        @items.each { |item| file.puts item.to_s }
      end
      LoggerManager.log_processed_file("Items saved to text file: #{filename}")
    end

    def save_to_json(filename = 'output/items.json')
      File.write(filename, @items.to_json)
      LoggerManager.log_processed_file("Items saved to JSON file: #{filename}")
    end

    def save_to_csv(filename = 'output/items.csv')
      CSV.open(filename, 'w') do |csv|
        csv << @items.first.keys if @items.any?
        @items.each { |item| csv << item.values }
      end
      LoggerManager.log_processed_file("Items saved to CSV file: #{filename}")
    end

    def save_to_yml
      Dir.mkdir('output/items_yml') unless Dir.exist?('output/items_yml') # Створення папки для YAML
      @items.each_with_index do |item, index|
        File.write("output/items_yml/item_#{index + 1}.yml", item.to_yaml)
      end
      LoggerManager.log_processed_file("Items saved to YAML files in directory: output/items_yml")
    end
  end

  class Configurator
    attr_reader :config
  
    def initialize
      @config = {
        run_website_parser: 0,     # Запуск розбору сайту
        run_save_to_csv: 0,        # Збереження даних в CSV форматі
        run_save_to_json: 0,       # Збереження даних в JSON форматі
        run_save_to_yaml: 0,       # Збереження даних в YAML форматі
        run_save_to_sqlite: 0,     # Збереження даних в базі даних SQLite
        run_save_to_mongodb: 0      # Збереження даних в базі даних MongoDB
      }
    end
  
    def configure(overrides)
      overrides.each do |key, value|
        if @config.key?(key)
          @config[key] = value
        else
          puts "Попередження: #{key} не є дійсним параметром конфігурації."
        end
      end
    end
  
    def self.available_methods
      new.config.keys
    end
  end
  
  class SimpleWebsiteParser
    attr_accessor :config, :agent, :item_collection
  
    def initialize(config_file)
      load_config(config_file)
      @agent = Mechanize.new
      @item_collection = []
      LoggerManager.initialize_logger(config_file)
    end
  
    def start_parse
      LoggerManager.log_processed_file("Starting to parse website...")
  
      if check_url_response(config['site']['base_url'])
        page = @agent.get(config['site']['base_url'])
        product_links = extract_products_links(page)
        product_links.each do |product_link|
          parse_product_page(product_link)
        end
      else
        LoggerManager.log_error("Base URL is not accessible: #{config['site']['base_url']}")
      end
    end
  
    def load_config(config_file)
      @config = YAML.load_file(config_file)
    rescue StandardError => e
      LoggerManager.log_error("Failed to load config: #{e.message}")
      exit
    end
  
    def extract_products_links(page)
      links = []
      page.search(config['site']['product_link_selector']).each do |element|
        links << element.attr('href')
      end
      links
    end
  
    def parse_product_page(product_link)
      LoggerManager.log_processed_file("Parsing product page: #{product_link}")
  
      # Якщо посилання відносне, додаємо до нього базову URL-адресу
      if product_link.start_with?('/')
        product_link = config['site']['base_url'] + product_link
      end
  
      if check_url_response(product_link)
        page = @agent.get(product_link)
        item = extract_product_data(page)
        item_collection << item
      else
        LoggerManager.log_error("Product URL is not accessible: #{product_link}")
      end
    end
  
    def extract_product_data(page)
      name = extract_product_name(page)
      description = extract_product_description(page)
      image_url = extract_product_image(page)
  
      # Створення об'єкта Item
      item = Item.new(
        title: name,
        description: description,
        image_path: download_image(image_url)
      )
  
      item
    end
  
    def extract_product_name(page)
      page.search(config['site']['name_selector']).text.strip
    end
  
    def extract_product_description(page)
      page.search(config['site']['description_selector']).text.strip
    end
  
    def extract_product_image(page)
      image_url = page.search(config['site']['image_selector']).attr('src')&.value
      image_url
    end
  
    def check_url_response(url)
      agent = Mechanize.new
      begin
        page = agent.get(url)
        page.code == '200' # Перевіряємо, що відповідь успішна
      rescue Mechanize::ResponseCodeError => e
        LoggerManager.log_error("Error fetching URL #{url}: #{e.message}")
        false
      rescue StandardError => e
        LoggerManager.log_error("Error fetching URL #{url}: #{e.message}")
        false
      end
    end
  
    def download_image(image_url)
      return nil if image_url.nil?
  
      image_name = image_url.split('/').last
      image_path = "media/#{image_name}"
      FileUtils.mkdir_p("media") unless Dir.exist?("media")
      File.open(image_path, 'wb') do |file|
        file.write open(image_url).read
      end
      LoggerManager.log_processed_file("Downloaded image: #{image_path}")
      image_path
    end
  end
  require 'sqlite3'
  require 'mongo'
  require 'yaml'
  
  class DatabaseConnector
    attr_reader :sqlite_db, :mongodb_db
  
    def initialize(config)
      @config = config
      @sqlite_db = nil
      @mongodb_db = nil
      connect_to_databases
    end
  
    def connect_to_databases
      connect_to_sqlite
      connect_to_mongodb
    end
  
    def close_connections
      close_sqlite_connection
      close_mongodb_connection
    end
  
    private
  
    def connect_to_sqlite
      sqlite_config = @config.dig('database_config', 'sqlite_database')
      if sqlite_config
        db_file = sqlite_config['db_file']
        begin
          @sqlite_db = SQLite3::Database.new(db_file)
          puts "Connected to SQLite database at #{db_file}."
        rescue SQLite3::Exception => e
          puts "Failed to connect to SQLite database: #{e.message}"
        end
      else
        puts "SQLite configuration is missing."
      end
    end
  
    def connect_to_mongodb
      mongodb_config = @config.dig('database_config', 'mongodb_database')
      if mongodb_config
        uri = mongodb_config['uri']
        db_name = mongodb_config['db_name']
        begin
          client = Mongo::Client.new(uri)
          @mongodb_db = client.use(db_name)
          puts "Connected to MongoDB database at #{uri}."
        rescue Mongo::Error => e
          puts "Failed to connect to MongoDB database: #{e.message}"
        end
      else
        puts "MongoDB configuration is missing."
      end
    end
  
    def close_sqlite_connection
      if @sqlite_db
        @sqlite_db.close
        puts "SQLite connection closed."
      end
    end
  
    def close_mongodb_connection
      if @mongodb_db
        @mongodb_db.close
        puts "MongoDB connection closed."
      end
    end
  end
end
