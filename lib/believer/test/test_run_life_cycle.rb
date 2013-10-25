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
          unless @saved_models.nil? || @saved_models.empty?
            @saved_models.each do |model|
              begin
                model.destroy
              rescue Exception => e
                puts "Could not destroy model #{model}: #{e}\n#{e.backtrace.join("\n")}"
              end
            end
            @saved_models = nil
          end
        end

        def after_save(model)
          @saved_models ||= []
          @saved_models << model
        end

      end

    end
  end
end
