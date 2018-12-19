require "tools"

module GemML
  class Perceptron

    private_class_method :new

    def initialize(weights:, bias:0)
      @weights = weights
      @bias = bias
    end

    def evaluate(data:,threshold:0,default:1)
      activation = GemML::Tools.dot_product(@weights, data[:features]) + @bias
      label = 0 if activation == threshold
      label ||= activation > threshold ? 1 : -1
      {:label => label, :activation => activation}
    end

    def Perceptron.train(data:, max_iterations:100)
      # Initialize weights and bias to 0
      weights = (0...data.first[:features].count).map {|i| 0}
      bias = 0
      
      # Proceed for the maximum iterations, or until the
      # perception converges
      (0...max_iterations).each do |i|
        puts "Beginning iteration #{i + 1}"
        # Randomizing the data each iteration speeds up convergence
        randomized_data = data.shuffle

        has_converged = true
        randomized_data.each do |example|
          
          # Calculate the activation for the point actvation = dot(w,d) + b
          activation = GemML::Tools.dot_product(weights, example[:features]) + bias
          puts "Activation #{activation}, #{example}"
          if example[:label] * activation <= 0
            # The perceptron incorrectly labeled the data,
            # adjust the weights and bias
            weights = (0...weights.count).map { |i|
               weights[i] + example[:label] * example[:features][i]
            }
            bias += example[:label]
            # Incorrect labeling => not yet converged
            has_converged = false
          end
        end

        # The training data was perfectly labeled, no more update 
        # will be made, create a new perception
        puts "The percepetron converged in #{i+1} iterations"
        return new(weights:weights, bias:bias) if has_converged
      end

      return new(weights:weights, bias:bias)
    end

  end
end