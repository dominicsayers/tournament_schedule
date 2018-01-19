require_relative 'permutation'

class Group
  def schedule
    matchups.permutation.each { |permutation| assess(permutation) }
    @favourite_permutation
  end

  private

  def initialize(data, group_name)
    puts "Group: #{group_name}" # debug

    @data = data
    @group_name = group_name
    @entrants = data.groups[group_name]

    @favourite_permutation = {}
    @favourite_permutation_score = 0
    @index = 0
    @percent_complete = 0
  end

  def entrant_names
    @entrant_names ||= @entrants.keys
  end

  def matchups
    @matchups ||= entrant_names.combination(2).to_a.shuffle
  end

  def permutation_count
    @permutation_count ||= (1..@matchups.length).reduce(:*) || 1
  end

  def assess(permutation)
    @index += 1
    percent_complete = 100 * @index / permutation_count

    if percent_complete > @percent_complete
      @percent_complete = percent_complete
      print "#{percent_complete}% "
    end

    # puts permutation.inspect # debug
    score = Permutation.new(@data, permutation).assess

    if score > @favourite_permutation_score
      puts "\nNew favourite: #{permutation.inspect}"
      @favourite_permutation = permutation
      @favourite_permutation_score = score
    end
  end
end
