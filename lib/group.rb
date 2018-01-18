class Group
  def schedule
    matchups.permutation.each { |permutation| assess(permutation) }
    favourite_permutation
  end

  private

  def initialize(entrants)
    @entrants = entrants
  end

  def entrant_names
    @entrant_names ||= entrants.keys
  end

  def matchups
    @matchups ||= entrant_names.combination(2).to_a.shuffle
  end

  def favourite_permutation
    @favourite_permutation ||= {}
  end

  def favourite_permutation_score
    @favourite_permutation_score ||= 0
  end

  def assess(permutation)
    score = Permutation.new(permutation).assess

    if score > favourite_permutation_score
      @favourite_permutation = permutation
      @favourite_permutation_score = score
    end
  end
end
