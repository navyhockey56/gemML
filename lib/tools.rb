module GemML
  module Tools
    class << self

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

    end
  end
end
