module Jekyll
  module Tags
    class SideBySide < Liquid::Block
      def initialize(tag_name, markup, tokens)
        @text = false
        super
      end

      def render(context)
        [
          "<section class=\"side-by-side\">",
          "<div>",
          render_all(@nodelist[1..-1], context),
          "</div>",
          render_all([@nodelist[0...1]], context),
          "</section>"
        ].join("\n")
      end

      def unknown_tag(tag, markup, tokens)
        if tag == 'text'
          @text = true
        else
          super
        end
      end
    end
  end
end

Liquid::Template.register_tag('sidebyside', Jekyll::Tags::SideBySide)
