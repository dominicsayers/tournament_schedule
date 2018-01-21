require_relative 'schedule'

class Group
  def schedule
    puts "Assessing #{permutation_count_pretty} permutations"
    matchups.permutation.each { |permutation| assess(permutation) }
    @best_schedule
  end

  def to_s
    <<~GROUP
      Group #{@group_name}
      #{@entrants.map { |name, club| "  " + name + " (" + club + ")" }.join("\n")}
    GROUP
  end

  private

  def initialize(data, group_name)
    puts "Group #{group_name}" # debug

    @data = data
    @group_name = group_name
    @entrants = data.groups[group_name]

    @best_schedule = nil

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
    @permutation_count ||= (1..matchups.length).reduce(:*) || 1
  end

  def permutation_count_pretty
    @permutation_count_pretty ||= permutation_count.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
  end

  def assess(permutation)
    show_progress
    schedule = Schedule.new(@data, permutation)
    return unless schedule.better_than? @best_schedule

    puts "\nNew favourite"
    puts schedule.to_s
    @best_schedule = schedule
  end

  def show_progress
    @index += 1
    percent_complete = 100 * @index / permutation_count

    if percent_complete > @percent_complete
      @percent_complete = percent_complete
      print "#{percent_complete}% "
    end
  end
end
