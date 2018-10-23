module ActiveAdmin
  module Views
    class Header < Component

      def build(namespace, menu)
        super(id: "header")

        @namespace = namespace
        @menu = menu
        @utility_menu = @namespace.fetch_menu(:utility_navigation)

        build_site_title
        build_global_navigation
        build_utility_navigation

        if current_user.present? && current_user.is_super_admin?
          build_account_selector
        end
      end


      def build_site_title
        insert_tag view_factory.site_title, @namespace
      end

      def build_global_navigation
        insert_tag view_factory.global_navigation, @menu, class: 'header-item tabs'
      end

      def build_utility_navigation
        insert_tag view_factory.utility_navigation, @utility_menu, id: "utility_nav", class: 'header-item tabs'
      end

      def build_account_selector
        html = "<form id='switch-account' target='' method='get'><select name='current_account_id'>"
        Account.order(Arel.sql('LOWER(name)')).select([:id, :name]).each do |account|
          if account[:id] == current_account.id
            html += "<option selected value='#{account[:id]}'>#{account[:name]}</option>"
          else
            html += "<option value='#{account[:id]}'>#{account[:name]}</option>"
          end
        end
        html += "</select></form>"
        current_arbre_element.add_child html.html_safe
      end
    end
  end
end
