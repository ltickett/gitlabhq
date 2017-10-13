module Boards
  module Issues
    class CreateService < Boards::BaseService
      attr_accessor :project

      def initialize(parent, project, user, params = {})
        @project = project

        super(parent, user, params)
      end

      def execute
        create_issue(creation_params)
      end

      private

      def creation_params
        params.merge(label_ids: [list.label_id, *board.label_ids],
                     weight: board.weight,
                     milestone_id: board.milestone_id,
                     assignee_ids: assignee_ids)
      end

      # This can be safely removed when the board
      # receive multiple assignee support.
      def assignee_ids
        @board_assignee ||= board.assignee

        return [] unless @board_assignee

        [@board_assignee.id]
      end

      def board
        @board ||= parent.boards.find(params.delete(:board_id))
      end

      def list
        @list ||= board.lists.find(params.delete(:list_id))
      end

      def create_issue(params)
        ::Issues::CreateService.new(project, current_user, params).execute
      end
    end
  end
end
