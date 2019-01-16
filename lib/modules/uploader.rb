module Database
  FOLDER_PATH = './lib/database/'.freeze
  FILE_PATH = 'stats'.freeze
  FORMAT_PATH = '.yml'.freeze
  PATH = FOLDER_PATH + FILE_PATH + FORMAT_PATH

  def save_to_db(player)
    File.open(PATH, 'a+') { |f| f.write player.to_yaml }
  end

  private

  def load_db
    YAML.load_stream(File.open(PATH))
  end
end
