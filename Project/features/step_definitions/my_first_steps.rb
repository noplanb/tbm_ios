Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(STEP_PAUSE)
end

# if scenario.source_tags_names.include? "@reinstall"
# 	reinstall_apps()
# end

Given /^I have fresh registration$/ do
	phone = "091" + ('1'..'9').to_a.shuffle[0,7].join
	steps %Q{
		@reinstall
    	Then I enter "Oksana" into input field number 1
   		Then I enter "Kovalchuk" into input field number 2
   		Then I enter "380" into input field number 3
   		Then I enter "#{phone}" into input field number 4
   	 	Then I touch the "SignIn" button
  	}
end



# #---------------------------- Scroll down untill find SomeLabel or timeout---------------------

# Given /^I scroll down to "(.*?)" label$/ do |label|

#   wait_poll({:until_exists => "label text:'#{label}'",
#              :timeout => 3}) do
#     scroll("tableView", :down)

# end

# #---------------------------- Check that element Disabled -------------------------------------

# Given /^I should see disabled "(.*?)" button$/ do |button|
# 	check_element_exists("button marked:'#{button}' isEnabled:0")
# end

# #---------------------------- Check that element Enabled --------------------------------------

# Given /^I should see enabled "(.*?)" button$/ do |button_add|
# 	check_element_exists("button marked:'#{button_add}' isEnabled:1")
# end

# #----------------------------- Keyboard Return/Enter button tap -------------------------------

# Given /^I touch the Return button$/ do
# 	keyboard_enter_char('Return')
# end

# #------------------------------ Check focus in Some Input Field -------------------------------

# Given /^I check focus in "(.*?)" input field$/ do |inputName| 
# 	check_element_exists("view:'UIResponder' isFirstResponder:1 placeholder:'#{inputName}'")
# end

# #------------------------------- Check that keyboard is unactive ------------------------------

# Given /^keypad should not be active$/ do 
#     res = element_exists( "keyboardAutomatic" )
#     if res
#         screenshot_and_raise "Expected keyboard to not be visible."
#     end


When(/^I pan left on the screen$/) do
  top_view = query().first
  rect = top_view['rect']

  from_x = 0
  from_y = rect['height'] * 0.5
  from_offset = {x: from_x, y: from_y}

  to_x = rect['width'] * 0.75
  to_y = from_y
  to_offset = {x: to_x, y: to_y}

  uia_pan_offset(from_offset, to_offset, {duration: 0.5})
  wait_for_none_animating
end


# #---------------------------- Scroll down untill find SomeLabel or timeout---------------------

# Given /^I scroll down to "(.*?)" label$/ do |label|

#   wait_poll({:until_exists => "label text:'#{label}'",
#              :timeout => 3}) do
#     scroll("tableView", :down)

# end

# #---------------------------- Check that element Disabled -------------------------------------

# Given /^I should see disabled "(.*?)" button$/ do |button|
# 	check_element_exists("button marked:'#{button}' isEnabled:0")
# end

# #---------------------------- Check that element Enabled --------------------------------------

# Given /^I should see enabled "(.*?)" button$/ do |button_add|
# 	check_element_exists("button marked:'#{button_add}' isEnabled:1")
# end

# #----------------------------- Keyboard Return/Enter button tap -------------------------------

# Given /^I touch the Return button$/ do
# 	keyboard_enter_char('Return')
# end

# #------------------------------ Check focus in Some Input Field -------------------------------

# Given /^I check focus in "(.*?)" input field$/ do |inputName| 
# 	check_element_exists("view:'UIResponder' isFirstResponder:1 placeholder:'#{inputName}'")
# end

# #------------------------------- Check that keyboard is unactive ------------------------------

# Given /^keypad should not be active$/ do 
#     res = element_exists( "keyboardAutomatic" )
#     if res
#         screenshot_and_raise "Expected keyboard to not be visible."
#     end

# #---------------------------------------------------------------------------------
Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(STEP_PAUSE)
end


# Given /^I have fresh registration$/ do
#    # macro "Then I enter \"Oksana\" into input field number 1"
#    # macro "Then I enter \"Kovalchuk\" into input field number 2"
#    # macro "Then I enter \"380\" into input field number 3"

#    # phone = "091" + ('1'..'9').to_a.shuffle[0,7].join
#    # macro "Then I enter phone into input field number 4"
#    # macro "Then I touch the \"SignIn\" button"
#    # macro "And I wait until I see \"gridView\""

# 	phone = "091" + ('1'..'9').to_a.shuffle[0,7].join
# 	steps %Q{
#     	Then I enter "Oksana" into input field number 1
#    		Then I enter "Kovalchuk" into input field number 2
#    		Then I enter "380" into input field number 3"
#    		Then I enter #{phone} into input field number 4"
#    	 	Then I touch the "SignIn" button
#    		And I wait until I see "gridView"
#   	}
# end

When(/^I pan left on the screen$/) do
  top_view = query().first
  rect = top_view['rect']

  from_x = 0
  from_y = rect['height'] * 0.5
  from_offset = {x: from_x, y: from_y}

  to_x = rect['width'] * 0.75
  to_y = from_y
  to_offset = {x: to_x, y: to_y}

  uia_pan_offset(from_offset, to_offset, {duration: 0.5})
  wait_for_none_animating
end


# #---------------------------- Scroll down untill find SomeLabel or timeout---------------------

# Given /^I scroll down to "(.*?)" label$/ do |label|

#   wait_poll({:until_exists => "label text:'#{label}'",
#              :timeout => 3}) do
#     scroll("tableView", :down)

# end

# #---------------------------- Check that element Disabled -------------------------------------

# Given /^I should see disabled "(.*?)" button$/ do |button|
# 	check_element_exists("button marked:'#{button}' isEnabled:0")
# end

# #---------------------------- Check that element Enabled --------------------------------------

# Given /^I should see enabled "(.*?)" button$/ do |button_add|
# 	check_element_exists("button marked:'#{button_add}' isEnabled:1")
# end

# #----------------------------- Keyboard Return/Enter button tap -------------------------------

# Given /^I touch the Return button$/ do
# 	keyboard_enter_char('Return')
# end

# #------------------------------ Check focus in Some Input Field -------------------------------

# Given /^I check focus in "(.*?)" input field$/ do |inputName| 
# 	check_element_exists("view:'UIResponder' isFirstResponder:1 placeholder:'#{inputName}'")
# end

# #------------------------------- Check that keyboard is unactive ------------------------------

# Given /^keypad should not be active$/ do 
#     res = element_exists( "keyboardAutomatic" )
#     if res
#         screenshot_and_raise "Expected keyboard to not be visible."
#     end

# #---------------------------------------------------------------------------------
