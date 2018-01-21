# frozen_string_literal: true

require_relative 'lib/tournament'
Tournament.new(filename: 'data/simple.yml').schedule
