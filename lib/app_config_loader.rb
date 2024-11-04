class AppConfigLoader
  def initialize
    @system_libs = %w[date] # Список системних бібліотек
    @loaded_files = []       # Масив для відстеження підключених файлів
  end

  def load_libs
    # Підключення системних бібліотек
    @system_libs.each do |lib|
      require lib
      @loaded_files << lib
    end

    # Підключення локальних бібліотек
    Dir.glob("libs/**/*.rb").each do |file|
      unless @loaded_files.include?(file)
        require_relative file
        @loaded_files << file
      end
    end
  end
end
