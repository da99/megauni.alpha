

module Enum_Map_Html_Menu

  def map_html_menu

    map { |orig|
      raw_results = yield(orig)

      selected, attrs = if raw_results.is_a?(Array)
        assert_size raw_results, 2
        raw_results
      else
        [raw_results, {}]
      end

      add_attrs = { 
        :selected? => selected, 
        :not_selected? =>!selected
      }

      if orig.is_a?(Hash)
        orig.update add_attrs
      else
        attrs.update add_attrs
      end
    }
  end

end # === module 
