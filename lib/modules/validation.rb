module Validation
  def validate_length_in_range?(word, min, max)
    word.length.between?(min, max)
  end

  def validate_presence?(entity)
    entity.empty?
  end

  def validate_match(entity)
    entity.split('').map(&:to_i).map(&:to_s).join('') == entity
  end

  def validate_length(entity, set_length)
    entity.length == set_length
  end
end
