module Codebreaker
  class Rules
    FOLDER_PATH = './'.freeze
    FILE_PATH = 'rules'.freeze
    FORMAT_PATH = '.txt'.freeze
    PATH = FOLDER_PATH + FILE_PATH + FORMAT_PATH

    def show_rules
      File.open(PATH, 'r') do |f|
        f.each_line { |line| puts line }
        f.close
      end
    end
  end
end
