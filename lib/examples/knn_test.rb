module GemML
  module KNNTest
    class << self

      def knn_data
        [
          {
            :label => true,
            :features => [0,0,0]
          },
          {
            :label => true,
            :features => [3,1,1]
          },
          {
            :label => true,
            :features => [2,1,2]
          },
          {
            :label => true,
            :features => [2,2,2]
          },
          {
            :label => false,
            :features => [4,2,3]
          },
          {
            :label => false,
            :features => [3,4,3]
          },
          {
            :label => false,
            :features => [3,3,3]
          },
          {
            :label => false,
            :features => [3,3,4]
          },
          {
            :label => true,
            :features => [3,0,0]
          }
        ]
      end

    end
  end
end