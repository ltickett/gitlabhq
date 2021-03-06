# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class Create < Chain::Base
          include Chain::Helpers

          # rubocop: disable CodeReuse/ActiveRecord
          def perform!
            ::Ci::Pipeline.transaction do
              pipeline.save!

              ##
              # Create environments before the pipeline starts.
              #
              pipeline.builds.each do |build|
                if build.has_environment?
                  project.environments.find_or_create_by(
                    name: build.expanded_environment_name
                  )
                end
              end
            end
          rescue ActiveRecord::RecordInvalid => e
            error("Failed to persist the pipeline: #{e}")
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def break?
            !pipeline.persisted?
          end
        end
      end
    end
  end
end
