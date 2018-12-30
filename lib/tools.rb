module GemML
  module Tools
    class << self

      # Given an array of arrays of fixnums or floats of fixed length, scales
      # the supplied index of all vectors within the array. With the least value
      # starting at :start, and the values ranges from :start to (:start + :range).
      # In the event all the features are the same value, then all will be scaled
      # to the :start value.
      #
      # @param [Array] data - An array of arrays of fixed length, containing numbers.
      # @param [Fixnum] index - The index to scale
      # @param [Number] start - The starting position to scale to (the least value
      #   will scale to this value). 
      # @param [Number] range - Determines the range of values the features will
      #   be scaled into. The largest feature will have value (:start + :range) 
      def scale_by_feature(data:, index:, start:0, range:1)
        raise 'Range must be positive' if range <= 0
        return data if data.empty?

        max = data.max { |a,b| a[index] <=> b[index] }[index]
        min = data.min { |a,b| a[index] <=> b[index] }[index]
        max_min_range = max - min + 0.0 # Force to Float
        
        # [ 1, 2, 5, 7, 10 ]
        length = data.first.count

        data.map { |point|
          front = point[0...index]
          back = point[(index + 1)...length] 

          scaled_feature = start if max_min_range == 0 
          scaled_feature ||= (((point[index] - min) / (max_min_range)) * range) + start
            
          front + [scaled_feature] + back
        }
      end

      # Given an array of arrays of numbers of fixed length, scales
      # every feature within each vector using scale_by_feature.
      #
      # @param [Array] data 
      # @param [Number | Array] start - The :start value from scale_by_feature, or an array of 
      #   :start values for each index.
      # @param [Number | Array] range - The :range value from scale_by_feature, or an array of
      #   :range values for each index.
      def scale_each_feature(data:, start:0, range:1)
        return data if data.empty?
        data_dup = data.dup
        (0...data.first.count).each { |i|
          start_val = start.class == Array ? start[i] : start
          range_val = range.class == Array ? range[i] : range
          data_dup = scale_by_feature(data: data_dup, index: i, start: start_val, range: range_val)
        }
        data_dup
      end

      # Scales the data over a set of features as opposed to a singe feature
      # by calculating the max and min value over all indexes specified, instead 
      # of treating the indexes seperately.
      def scale_by_features(data:, indexes:, start:0, range:1)
        raise 'Range must be positive' if range <= 0
        return data if data.empty?

        max_vector = data.max { |a,b|
          a_index = indexes.max { |i,j| a[i] <=> a[j] }
          b_index = indexes.max { |i,j| b[i] <=> b[j] } 
          a[a_index] <=> b[b_index] 
        }
        max = max_vector[indexes.max { |i,j| max_vector[i] <=> max_vector[j] }]
       
        min_vector = data.min { |a,b|
          a_index = indexes.min { |i,j| a[i] <=> a[j] }
          b_index = indexes.min { |i,j| b[i] <=> b[j] } 
          a[a_index] <=> b[b_index] 
        }
        min = min_vector[indexes.min { |i,j| min_vector[i] <=> min_vector[j] }]

        max_min_range = max - min + 0.0 # Force to Float

        data.map { |point|
          # Scale the features
          scaled_values = indexes.map { |index| 
            if max_min_range == 0 
              start 
            else
              (((point[index] - min) / max_min_range) * range) + start
            end
          }

          # Rebuild the vector with the scaled values
          (0...point.count).map { |index| 
            indexes.include?(index) ? scaled_values.delete_at(0) : point[index] 
          }
        }

      end

      # Scales the specified feature into range [-1, 1] (exclusive)
      # by dividing each feature by 10^d where d is the least integer
      # such that max(|scaled(val)|) < 1.
      def decimal_normalize(data:, index:)
          return data if data.empty?
          max = data.max { |a,b| a[index].abs <=> b[index].abs }[index].abs
          d = 0
          while (max / (10 ** d)) >= 1
            d += 1
          end
          normalizer = (10 ** d).to_f
          length = data.first.count
          data.map { |point| 
            front = point[0...index]
            back = point[(index + 1)...length] 

            scaled_feature = point[index] / normalizer

            front + [scaled_feature] + back
          }
      end

      def z_score_normalize(data:, index:)
        return data if data.empty?
        mean = mean_value(data: data, index:index)
        variance = determine_variance(data: data, index: index, mean: mean)
        standard_deviation = determine_standard_deviation(data: data, index: index, variance: variance)
        length = data.first.count
        data.map { |point|
          front = point[0...index]
          back = point[(index + 1)...length] 

          scaled_feature = (point[index] - mean) / standard_deviation

          front + [scaled_feature] + back
        }
      end

      # Calculates the mean for the feature at the specified index
      def mean_value(data:, index:)
        sum = 0
        data.each { |point| 
          sum += point[index]
        }
        sum / data.count.to_f
      end

      # Determines the variance for the feature at the speicified index
      def determine_variance(data:, index:, mean:nil)
        mean ||= mean_value(data:data, index:index)
        sum = 0
        data.each { |point| 
          sum += (point[index] - mean) ** 2
        }
        sum / data.count.to_f
      end

      # Determines the standard deviation of the feature at the
      # the specified index
      def determine_standard_deviation(data:, index:, variance:nil)
        variance ||= determine_variance(data:data, index: index)
        Math.sqrt(variance)
      end

      def normalize_data(data)
        # Normalize the data
        normalizers = get_normalizers(data)
        normalized_data = data.map {|data_point| normalize_point(data_point, normalizers) }

        # Return the normalizers and the normalized data
        {:data => normalized_data, :normalizers => normalizers}
      end

      # [min, max - min]
      def get_normalizers(data)
        (0...data.first.count).map do |i|
          min_point = data.min { |a, b| a[i] <=> b[i] }
          max_point = data.max { |a, b| a[i] <=> b[i] }
          [Float(min_point[i]), max_point[i] - min_point[i]]
        end
      end

      def normalize_point(data_point, normalizers)
        (0...data_point.count).map do |i|
          (data_point[i] - normalizers[i].first) / normalizers[i].last rescue 0
        end
      end

      def vector_distance(vector1, vector2)
        sum = 0
        (0...vector1.count).each {|i| sum += (vector1[i] - vector2[i]) ** 2 }
        Math.sqrt(sum)
      end

      def dot_product(vector1, vector2)
        sum = 0
        (0...vector1.count).each {|i| sum += vector1[i] * vector2[i] }
        sum
      end 

    end
  end
end
