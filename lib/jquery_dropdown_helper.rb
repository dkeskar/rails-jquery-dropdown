# Tag and options helper to construct jQuery drop-down menus. 
# http://www.filamentgroup.com/lab/jquery_ipod_style_and_flyout_menus/
#
module ActionView
	module Helpers
		module FormTagHelper
			
			# Creates a set of tags to enable jQuery + ThemeRoller drop-down menus. 
			# The menus support hieararchies with back buttons, bread-crumbs and
			# flyout behavior. 
			
			# ==== Parameters
			# * <tt>field</tt> The id of an associated field, which will be used
			# to store the value of the selected menu item. 
			# * <tt>name</tt> The initial text that is displayed by the menu, which
			# typically indicates the function of this menu. e.g. "Choose Category"
			# * <tt>content</tt> The content describing the menu items. This can 
			# be a String of <ul><li><a>... tags as required by the menu, or it can 
			# be Array data as accepted by the <tt>options_for_dropdown</tt> helper.
			#
			# ==== Options
			# * <tt>:id</tt> Override the field identifier with this specified id. 
			# The dropdown tags are identified as _id_-selector and _id_-items. 
			# Spaces, [ and ] are substituted with a - (dash).
			# * <tt>:style</tt> Additional HTML style attributes to apply. 
			# * <tt>:select</tt> Javascript function to call when a menu item is 
			# selected. This function is provided the menu item value. 
			#
			# ==== Examples
			# 	<%= hidden_field_tag sort_criteria %>
			# 	<%= dropdown_tags sort_criteria, 'Select Criteria', 
			# 			%w(Category Status Amount-High Amount-Low) %>
			# 	# => Creates a drop-down with four items. No callback specified
			#
			# 	<%= hidden_field_tag 'budget_main', @budgets.first.id %>
			# 	<%= dropdown_tags 'budget_main', @budgets.first.name, 
			#				@budgets.map {|x| [x.name, x.id]}, :select => 'onBudgetSelect' %>
			# 	# => A drop down menu comprising of budget items, showing name of 
			# 	# first budget item, with resultant javascript callback 
			# 	# onBudgetSelect(selected_value) when a menu item is selected.
			#	
			def dropdown_tags(field, name, content, options={})
				id = options[:id] || "#{field.gsub(/[\[\]\s]/, '-')}-selector"
				style = options[:style] ? %{style="#{options[:style]}"} : ""
				on_sel_func = options[:select] || "";
				markup = <<-END
				<a id="#{id}" class="fg-button fg-button-icon-right ui-widget ui-corner-all ui-state-default" href="##{id}-items" tabindex="0" #{style}>
					<span class="ui-icon ui-icon-triangle-1-s"></span>#{name}</a>
				<div id="#{id}-items" class="hidden" #{style}>#{options_for_fancy_menu(content)}</div>
				<script type="text/javascript">
					jQuery('##{id}').menu({
						content: jQuery('##{id}-items').html(),
						flyOut: true,
						posX: 'left', 
						posY: 'bottom',
						directionV: 'down',
						maxHeight: 400,
						detectV: false,
						showSpeed: 350,
						chooseItem: function(selection) {
							jQuery('##{id}').html(
								'<span class="ui-icon ui-icon-triangle-1-s"></span>' + 
								jQuery(selection).text()
							);
							var vid = jQuery(selection).attr('value');
							jQuery('##{field}').attr('value', vid);
							#{on_sel_func}(vid);
						}
					});
				</script>
				END
			end
		end
		
		module FormOptionsHelper
			
			# Constructs the appropriate HTML options string for dropdown menus
			# as constructed via <tt>dropdown_tags</tt>.
			#
			# ==== Parameters
			# <tt>content</tt> An Array, each element of which contains either one
			# two or three elements. The first element is the text of the menu item. 
			# If a second element is provided, it is used as the value associated 
			# with the menu item. An optional third element can be another array
			# corresponding to a submenu, for a hierarchical menu item.
			# If only one element is provided per menu item, that element is used
			# as the text as well as the value. 
			#
			# The value of the menue item is returned when user selects the menu item. 
			#
			def options_for_dropdown(contents)
				return contents if contents.is_a?(String) and contents =~ /^<ul/i
				list_items = contents.inject([]) do |list, element|
					text, value = dropdown_content_text_and_value(element)
					submenu = if element.respond_to?(:third) and element.third
						options_for_fancy_menu(element.third)
					else
						""
					end
					list << %{<li><a href="#" value="#{value}">#{text}</a>#{submenu}</li>}
				end
				%{<ul>#{list_items.join("\n")}</ul>}
			end

			def dropdown_content_text_and_value(content)
				if !content.is_a?(String) and content.respond_to?(:first) and content.respond_to?(:second)
					[content.first, content.second]
				else
					[content, content]
				end
			end
		end
	end
end