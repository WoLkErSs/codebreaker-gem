module Codebreaker
  class Statistics
    include Database

    def winners(base)
      data = multi_sort(base)
      array_rows = to_table(data)
      table(array_rows)
    end

    private

    def to_table(data)
      rows = []
      data.each do |i|
        row = []
        row << i.name
        row << i.difficulty
        row << i.attempts_total
        row << i.attempts_used
        row << i.hints_total
        row << i.hints_used
        rows << row
      end
      rows
    end

    def multi_sort(items)
      items.sort_by { |x| [x.difficulty, x.attempts_used, x.hints_used] }
    end

    def table(rows)
      title = [
        I18n.t('table_fields.name'),
        I18n.t('table_fields.difficulty'),
        I18n.t('table_fields.attempts_total'),
        I18n.t('table_fields.attempts_used'),
        I18n.t('table_fields.hints_total'),
        I18n.t('table_fields.hints_used')
      ]
      Terminal::Table.new title: I18n.t('table_heder'), headings: title, rows: rows
    end
  end
end
