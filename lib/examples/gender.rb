require 'core/decision_tree'

module Gender
  module Examples
    class << self
      
      def long_hair?(data_point)
        data_point[:long_hair]
      end

      def plays_football?(data_point)
        data_point[:plays_football]
      end

      def taller_than_5f6in?(data_point)
        data_point[:taller_than_5f6in]
      end

      def shaves_legs?(data_point)
        data_point[:shaves_legs]
      end

      def create_gender_data
        p1 = {
          label: 'b',
          long_hair: false,
          plays_football: true,
          taller_than_5f6in: true,
          shaves_legs: false
        }

        p2 = {
          label: 'b',
          long_hair: true,
          plays_football: true,
          taller_than_5f6in: true,
          shaves_legs: false
        }

        p3 = {
          label: 'b',
          long_hair: false,
          plays_football: false,
          taller_than_5f6in: true,
          shaves_legs: true
        }

        p4 = {
          label: 'b',
          long_hair: false,
          plays_football: false,
          taller_than_5f6in: true,
          shaves_legs: false
        }

        p5 = {
          label: 'g',
          long_hair: true,
          plays_football: true,
          taller_than_5f6in: false,
          shaves_legs: true
        }

        p6 = {
          label: 'g',
          long_hair: true,
          plays_football: false,
          taller_than_5f6in: false,
          shaves_legs: true
        }

        p7 = {
          label: 'g',
          long_hair: false,
          plays_football: false,
          taller_than_5f6in: false,
          shaves_legs: true
        }

        p8 = {
          label: 'g',
          long_hair: true,
          plays_football: false,
          taller_than_5f6in: true,
          shaves_legs: true
        }

        p9 = {
          label: 'g',
          long_hair: true,
          plays_football: false,
          taller_than_5f6in: false,
          shaves_legs: false
        }

        p10 = {
          label: 'b',
          long_hair: false,
          plays_football: false,
          taller_than_5f6in: true,
          shaves_legs: true
        }

        data = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]
        test_data = [data.delete_at(rand(data.count)), data.delete_at(rand(data.count))]

        { training: data, test: test_data }
      end

      def create_gender_dt
        data = create_gender_data
        evaluators = []
        evaluators << GemML::DTEvaluator.new(evaluator: method(:long_hair?), range: [true, false])
        evaluators << GemML::DTEvaluator.new(evaluator: method(:plays_football?), range: [true, false])
        evaluators << GemML::DTEvaluator.new(evaluator: method(:taller_than_5f6in?), range: [true, false])
        evaluators << GemML::DTEvaluator.new(evaluator: method(:shaves_legs?), range: [true, false])
        tree = GemML::DecisionTree.train(data: data[:training], evaluators: evaluators)
        {:tree => tree, :data => data}
      end

    end
  end
end
