module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document

        def build(*args)
          super
          add_classes_to_body
          build_active_admin_head
          build_page
        end

        private

        def add_classes_to_body
          @body.add_class(params[:action])
          @body.add_class(params[:controller].tr('/', '_'))
          @body.add_class("active_admin")
          @body.add_class("logged_in")
          @body.add_class(active_admin_namespace.name.to_s + "_namespace")
        end

        def build_active_admin_head
          within @head do
            insert_tag Arbre::HTML::Title, [title, render_or_call_method_or_proc_on(self, active_admin_namespace.site_title)].compact.join(" | ")
            active_admin_application.stylesheets.each do |style, options|
              text_node stylesheet_link_tag(style, options).html_safe
            end

            active_admin_application.javascripts.each do |path|
              text_node(javascript_include_tag(path))
            end

            if active_admin_application.favicon
              text_node(favicon_link_tag(active_admin_application.favicon))
            end

            text_node csrf_meta_tag
          end
        end

        def build_page
          within @body do
            div id: "wrapper" do
              build_unsupported_browser
              build_header
              build_title_bar
              build_page_content
              build_footer
            end
          end
        end

        def build_unsupported_browser
          if active_admin_namespace.unsupported_browser_matcher =~ env["HTTP_USER_AGENT"]
            insert_tag view_factory.unsupported_browser
          end
        end

        def build_header
          insert_tag view_factory.header, active_admin_namespace, current_menu
        end

        def build_title_bar
          insert_tag view_factory.title_bar, title, action_items_for_action
        end

        def build_page_content
          build_flash_messages
          div id: "active_admin_content", class: (skip_sidebar? ? "without_sidebar" : "with_sidebar") do
            build_main_content_wrapper
            build_sidebar unless skip_sidebar?
          end
        end

        def build_flash_messages
          div class: 'flashes' do
            flash_messages.each do |type, message|
              div message, class: "flash flash_#{type}"
            end
          end
        end

        def build_main_content_wrapper
          div id: "main_content_wrapper" do
            div id: "main_content" do
              main_content
            end
          end
        end

        def main_content
          I18n.t('active_admin.main_content', model: title).html_safe
        end

        def title
          self.class.name
        end

        # Set's the page title for the layout to render
        def set_page_title
          set_ivar_on_view "@page_title", title
        end

        # Returns the sidebar sections to render for the current action
        def sidebar_sections_for_action
          if active_admin_config && active_admin_config.sidebar_sections?
            active_admin_config.sidebar_sections_for(params[:action], self)
          else
            []
          end
        end

        def action_items_for_action
          if active_admin_config && active_admin_config.action_items?
            active_admin_config.action_items_for(params[:action], self)
          else
            []
          end
        end

        # Renders the sidebar
        def build_sidebar
          div id: "sidebar" do
            sidebar_sections_for_action.collect do |section|
              sidebar_section(section)
            end
          end
        end

        def skip_sidebar?
          sidebar_sections_for_action.empty? || assigns[:skip_sidebar] == true
        end

        # Renders the content for the footer
        def build_footer
          if ENV['GOOGLE_ANALYTICS_ID'].present?
            within @head do
              script "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)})(window,document,'script','//www.google-analytics.com/analytics.js','ga');ga('create', '#{ENV['GOOGLE_ANALYTICS_ID']}', 'auto');ga('send', 'pageview');".html_safe
            end
          end

          div id: 'footer' do
            para "Powered by #{link_to("WaysAct", "http://www.waysact.com")}".html_safe
            current_arbre_element.add_child(ArbreVerbatimElement.new(include_gon))
          end
        end
      end
    end
  end
end

class ArbreVerbatimElement < Arbre::Element
  def initialize(verbatim_content)
    super
    @verbatim_content = verbatim_content
  end

  def to_s
    @verbatim_content
  end
end

class ActiveAdmin::Views::Pages::Base < Arbre::HTML::Document

  private

  def build_page
    within @body do
      div :id => "wrapper" do
        build_header
        build_title_bar
        build_page_content
        build_footer
      end

      div :id => "is_mothership_flag", :style => 'display: none;' do
        current_account.is_mothership ? "true" : "false"
      end

      div :id => "is_translator_flag", :style => 'display: none;' do
        current_user.is_translator? ? "true" : "false"
      end

      div id: 'is_client_flag', style: 'display: none;' do
        current_user.is_client? ? 'true' : 'false'
      end
    end
  end
end
