module GemML

  # Encapsulates a decision tree node's evaluation method, along with
  # with the possible range of outputs from that method
  class DTEvaluator

    attr_reader :evaluator, :range

    # @param [Procedure] evaluator - Given any data point, produces an output within the given range
    # @param [Array] range - All possible outputs of the evaulator
    def initialize(evaluator:, range:)
      @evaluator = evaluator
      @range = range
    end

    # Evaluates the given data point
    def evaluate(data)
      @evaluator.call(data)
    end

    # Iterates over the range
    def each 
      @range.each {|val| yield val }
    end

  end

  # Represents a decision tree designed to evaulate each data point
  # into any finite range of outputs at each node. This allows each node the
  # possibility of having any number of children nodes (with that number not having
  # to be constant across nodes).
  class DecisionTree

    private_class_method :new
    attr_reader :evaluator, :branches, :label

    def initialize(evaluator:nil, branches:nil, label:nil)
      @evaluator = evaluator
      @branches = branches
      @label = label
    end

    def evaluate(data)
      return @label if @label
      evaluation = @evaluator.evaluate(data)
      @branches[evaluation].evaluate(data) 
    end

    # 
    # @param [Hash] data 
    # @param [Array] evaluators
    # @param [Fixnum] max_depth
    # @param [Fixnum] current_depth
    def self.train(data:, evaluators:, max_depth:nil, current_depth:0)

      # Base Case
      if evaluators.empty? || current_depth == max_depth
        # There are no evaluators left
        # We want to select the label that is most common among the data
        
        # Group the data by label
        grouped_data = data.group_by { |d| d[:label] }

        # Rank labels based on popularity
        ranked_data = grouped_data.group_by {|arr| arr.last.count }
        max_rank = ranked_data.keys.max
        
        # Select the label at random from the maximum ranking labels
        max_labels = ranked_data[max_rank]
        label = max_labels[rand(max_labels.count)].first

        # Create and return a DecisionTree for the determined label
        return new(label: label)
      end


      # Base Case
      # Check if all the data is labeled the same. If so, there is nothing we can learn.
      grouped_data = data.group_by { |d| d[:label] }
      if grouped_data.count == 1
        # Create and return a DecisionTree for the only label
        return new(label: grouped_data.keys.first)
      end

      # Need to determine which evaluator to use in order to branch the data

      # Score the evaluators
      scored_evaluators = evaluators.map do |evaluator|
        
        # Keeps track of the evaulators score
        score = 0 

        # Group the data by the evaulators output
        branched_data = data.group_by { |example| evaluator.evaluate(example) }

        # For each grouped subset, determine the most popular label.
        # Each branch will contribute the +1 to the score for every
        # example contained within the most popular labeled subset
        branched_data.values.each do |subset|
          # Group the data by label
          labeled_subsets = subset.group_by { |example| example[:label] }
          # Add the number of examples in the most popular labeled group to the score
          score += labeled_subsets.values.max { |a,b| a.count <=> b.count }.count
        end

        # Map the evaulator to the score and itself
        [score, evaluator]
      end

      # Need to determine the max scoring evaluators and then choose one at random

      # Group the evaluators by their score
      scored_evaulator_groupings = scored_evaluators.group_by { |arr| arr.first }
      # Determine the max score
      max_score = scored_evaulator_groupings.keys.max
      # Retrieve the max scoring evaluators
      max_scoring_evaluators = scored_evaulator_groupings[max_score]
      # Select the evaluator at random from the max scoring evaluators
      evaluator = max_scoring_evaluators[rand(max_scoring_evaluators.count)].last
      # Remove the selected evaluator from the rest of the group
      remaining_evaluators = evaluators.dup
      remaining_evaluators.delete(evaluator)
      
      # Need to train the branches of the new node to be created
      branches = {}
      
      # Branch the data based on the selected evaluator
      branched_data = data.group_by { |example| evaluator.evaluate(example)}
      # Train a tree for each branch the evaluator has
      evaluator.each do |branch_label|
        # Get the subset of data is mapped to by the branch label
        # If no data is mapped to, use all the data available.
        branched_subset = branched_data[branch_label] || data
        # Train the branch
        branches[branch_label] = DecisionTree.train(
            data: branched_subset, 
            evaluators:remaining_evaluators,
            current_depth: current_depth + 1,
            max_depth: max_depth
          )
      end

      # Create the new tree
      new(evaluator:evaluator, branches:branches)
    end

    # Determines how well the given tree doesn't against the given data set
    # @param [Array] data
    # @param [GemMl::DecisionTreee] tree
    def DecisionTree.accuracy(data:, tree:)
      number_correct = data.select { |example| tree.evaluate(example) == example[:label] }.count
      number_correct / data.count
    end
 
  end
end