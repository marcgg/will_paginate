require 'will_paginate/core_ext'
require 'will_paginate/view_helpers/base'
require 'action_view'
require 'will_paginate/view_helpers/link_renderer'

module WillPaginate
  module ViewHelpers
    # ActionView helpers for Rails integration
    module ActionView
      include WillPaginate::ViewHelpers::Base
      
      def will_paginate(collection = nil, options = {})
        options, collection = collection, nil if collection.is_a? Hash
        unless collection or !controller
          collection_name = "@#{controller.controller_name}"
          collection = instance_variable_get(collection_name)
          raise ArgumentError, "The #{collection_name} variable appears to be empty. Did you " +
            "forget to pass the collection object for will_paginate?" unless collection
        end

        super(collection, options.symbolize_keys)
      end
      
      # Wrapper for rendering pagination links at both top and bottom of a block
      # of content.
      # 
      #   <% paginated_section @posts do %>
      #     <ol id="posts">
      #       <% for post in @posts %>
      #         <li> ... </li>
      #       <% end %>
      #     </ol>
      #   <% end %>
      #
      # will result in:
      #
      #   <div class="pagination"> ... </div>
      #   <ol id="posts">
      #     ...
      #   </ol>
      #   <div class="pagination"> ... </div>
      #
      # Arguments are passed to a <tt>will_paginate</tt> call, so the same options
      # apply. Don't use the <tt>:id</tt> option; otherwise you'll finish with two
      # blocks of pagination links sharing the same ID (which is invalid HTML).
      def paginated_section(*args, &block)
        pagination = will_paginate(*args).to_s
        content = pagination + capture(&block) + pagination
        concat content, block.binding
      end
    end
  end
end

ActionView::Base.class_eval { include WillPaginate::ViewHelpers::ActionView }

if defined?(ActionController::Base) and ActionController::Base.respond_to? :rescue_responses
  ActionController::Base.rescue_responses['WillPaginate::InvalidPage'] = :not_found
end
