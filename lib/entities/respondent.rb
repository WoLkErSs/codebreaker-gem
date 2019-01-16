module Codebreaker
  class Respondent
    def show_message(line)
      puts I18n.t(line)
    end

    def show(argument)
      puts argument
    end
  end
end
