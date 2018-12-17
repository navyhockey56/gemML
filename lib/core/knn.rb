require "tools"

module GemML
  class KNN

    attr_reader :data, :normalizers

    # data - :features=[], :label
    def initialize(data)
      normalized_output = GemML::KNN.normalize_data(data)
      @normalizers = normalized_output[:normalizers]
      @data = normalized_output[:data]
    end

    def evaluate(data_point:, k:3)

      # Normalize the point relative to the rest of the data
      data_point = normalize_point(data_point)

      # locate nearest neighbor
      neighbors = []
      (@data).each do |example|
        # calculate distance
        distance = GemML::Tools.vector_distance(data_point[:features], example[:features])

        if neighbors.count < k
          # There's not enough neighbors, so this point will be a neighbor by default
         (neighbors << {:distance => distance, :data => example })
        else 
          # Determine the neighbor that's furthest away
          furthest_neighbor = neighbors.max{|a,b| a[:distance] <=> b[:distance]}
          # Check to see if the current point is closer
          if furthest_neighbor[:distance] > distance
            # Replace the further away neighbor with the current point
            neighbors.delete(furthest_neighbor) 
            neighbors << {:distance => distance, :data => example }
          end
        end

      end

      # Time to determine the label of the given point

      # Group the neighbors by their labels
      labeled_neighbors = neighbors.group_by {|neighbor| neighbor[:data][:label] }
      #puts "#{labeled_neighbors}"
      # Group the labels by their count
      scored_neigbors = labeled_neighbors.group_by { |k,v| v.count }
      # Determine the highest label count
      max_count = scored_neigbors.keys.max
      # Retrieve the labels with the max count
      max_labels = scored_neigbors[max_count].map { |arr| arr.first }
      # Pick a max label at random as the label for this point
      { 
        :label => max_labels[rand(max_labels.count)],
        :neighbors => neighbors,
        :normalize_data => data_point
      }
    end

    def KNN.accuracy(data:, knn:, k:3)
      number_correct = data.select { |example| 
        knn.evaluate(data_point:example,k:k)[:label] == example[:label] 
      }.count
      number_correct / data.count
    end

    def KNN.normalize_data(data)
      features = data.map {|data_point| data_point[:features] } 
      normalized_output = GemML::Tools.normalize_data(features)
      normalize_data = (0...data.count).map do |i|
        {:label => data[i][:label], :features => normalized_output[:data][i] }
      end
      normalized_output[:data] = normalize_data
      normalized_output
    end

    def normalize_point(data_point)
      {
        :label => data_point[:label], 
        :features => GemML::Tools.normalize_point(data_point[:features], @normalizers) 
      }
    end

  end
end