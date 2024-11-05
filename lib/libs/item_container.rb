require 'faker'
require_relative 'logger_manager'

# Set Faker's locale to English
Faker::Config.locale = 'en'

module ItemContainer
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def class_info
      "Class: #{name}, Version: 1.0"
    end

    def object_count
      @object_count ||= 0
    end

    def increment_object_count
      @object_count = object_count + 1
    end
  end

  module InstanceMethods
    def add_item(item)
      items << item
      self.class.increment_object_count
      MyApplicationKFC::LoggerManager.log_processed_file("Item added: #{item}")
    end

    def remove_item(item)
      items.delete(item)
      MyApplicationKFC::LoggerManager.log_processed_file("Item removed: #{item}")
    end

    def delete_items
      items.clear
      MyApplicationKFC::LoggerManager.log_processed_file("All items deleted")
    end

    def method_missing(method_name, *args, &block)
      if method_name == :show_all_items
        items.each { |item| puts item }
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name == :show_all_items || super
    end
    
    def generate_test_items(count = 5)
      count.times do
        item = {
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
      }
        add_item(item)
      end
      MyApplicationKFC::LoggerManager.log_processed_file("Generated #{count} test items")
    end
  end
end
