module Believer
  module Test
    # Controls the life cycle for all objects created in a test
    module TestRunLifeCycle
      extend ActiveSupport::Concern

      included do
        Believer::Base.observers = Destructor

        after(:each) do
          Destructor.instance.cleanup
        end
      end

      # Detroys all CqlRecord::Base instances created
      class Destructor < Believer::Observer
        observe Believer::Base

        def cleanup
          unless @observed_models.nil? || @observed_models.empty?
            @observed_models.each do |model|
              begin
                model.destroy
              rescue Exception => e
                puts "Could not destroy model #{model}: #{e}\n#{e.backtrace.join("\n")}"
              end
            end
            @observed_models = nil
          end
        end

        def observed_models
          return @observed_models.dup unless @observed_models.nil?
          []
        end

        def after_save(model)
          @observed_models ||= []
          @observed_models << model
        end

      end

    end
  end
end
