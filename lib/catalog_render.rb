require 'fileutils'
require 'yaml'

class ProductDirectoryManager
  BASE_DIR = File.join(__dir__, '..', 'config', 'products')

  CATEGORIES = [
    'Fantasy',
    'Family',
    'Drama',
    'Anime',
    'Documentary',
    'Crime',
    'Comedy'
  ]

  def initialize
    create_products_directory
    create_category_directories
  end

  private

  def create_products_directory
    # Створюємо базовий каталог для продуктів, якщо його не існує
    FileUtils.mkdir_p(BASE_DIR)
  end

  def create_category_directories
    CATEGORIES.each do |category|
      category_dir = File.join(BASE_DIR, category.downcase) # Перетворюємо на нижній регістр
      FileUtils.mkdir_p(category_dir) # Створюємо підкаталог для категорії
      puts "Створено каталог: #{category_dir}" # Виводимо повідомлення
    end
  end
end

# Створюємо екземпляр менеджера каталогів
ProductDirectoryManager.new
