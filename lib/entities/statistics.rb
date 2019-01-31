module Codebreaker
  class Statistics
    include Database

    COLUMN_NUMBERS = {
      name: 0,
      level: 1,
      attempts_left: 2,
      attempts_total: 3,
      have_left: 4,
      hints_total: 5,
      date: 6
    }.freeze

    def winners(base)
      data = multi_sort(base)
      to_table(data)
    end

    private

    def to_table(data)
      rows = []
      data.map do |i|
        row = []
        row << i.name
        row << i.difficulty
        row << i.attempts_left
        row << i.attempts_total
        row << i.have_hints
        row << i.hints_total
        row << i.date
        rows << row
      end
      rows
    end

    def multi_sort(items)
      items.sort_by { |player| [player.difficulty, player.attempts_used, player.hints_used] }
    end
  end
end
