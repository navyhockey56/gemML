require "tools"

module GemML
  class Perceptron

    private_class_method :new

    def initialize(weights:, bias:0)
      @weights = weights
      @bias = bias
    end

    def evaluate(data:,threshold:0,default:1)
      activation = GemML::Tools.dot_product(@weights, data[:data]) + @bias
      return 0 if activation == threshold
      activation > threshold ? 1 : -1
    end

    def Perceptron.train(data:data, max_iterations:10)
      # Initialize weights and bias to 0
      weights = (0..data.first[:data].count).map {|i| 0}
      bias = 0
      
      # Proceed for the maximum iterations, or until the
      # perception converges
      (0..max_iterations).each do |i|

        # Randomizing the data each iteration speeds up convergence
        randomized_data = data.suffle

        has_converged = true
        randomized_data.each do |example|
          # Calculate the activation for the point actvation = dot(w,d) + b
          activation = GemML::Tools.dot_product(weights, example[:data]) + bias
          if activation <= 0
            # The perceptron incorrectly labeled the data,
            # adjust the weights and bias
            weights.map! {|w| w + example[:label] * example[:data]}
            bias += example[:label]
            # Incorrect labeling => not yet converged
            has_converged = false
          end
        end

        # The training data was perfectly labeled, no more update 
        # will be made, create a new perception
        return new(weights:weights, bias:bias) if has_converged
      end

      return new(weights:weights, bias:bias)
    end

  end
end