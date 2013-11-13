module Believer
  module Test
    # Controls the life cycle for all objects created in a test
    module TestRunLifeCycle
      extend ActiveSupport::Concern

      included do

        Believer::Base.after_save do |model|
          Destructor.instance.after_save(model)
        end

        after(:each) do
          Destructor.instance.cleanup
        end
      end

      # Detroys all CqlRecord::Base instances created
      class Destructor
        include Singleton

        def counters_action
          if @counters_action.nil?
            begin
              @counters_action = Believer::Base.environment.believer_configuration[:test][:life_cycle][:counters].to_sym
            rescue
              @counters_action = :destroy
            end
          end
          @counters_action
        end

        def should_destroy?(model)
          #return false if model.is_counter_instance? && retain_counter_models?
          true
        end

        def cleanup
          @observed_models.each do |model|
            begin
              if model.is_counter_instance?
                case counters_action
                  when :destroy
                    model.destroy if should_destroy?(model)
                  when :reset
                    model.reset_counters!
                  when :retain
                end
              else
                model.destroy if should_destroy?(model)
              end
            rescue Exception => e
              puts "Could not destroy model #{model}: #{e}\n#{e.backtrace.join("\n")}"
            end
          end unless @observed_models.nil? || @observed_models.empty?
          @observed_models = nil
        end

        def observed_models
          return @observed_models.dup.to_a unless @observed_models.nil?
          []
        end

        def after_save(model)
          @observed_models ||= Set.new
          @observed_models << model
        end

      end

    end
  end
end
