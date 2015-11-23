Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(STEP_PAUSE)
end


Given /^fresh registration$/ do
   macro "Then I enter \"Oksana\" into input field number 1"
   macro "Then I enter \"Kovalchuk\" into input field number 2"
   macro "Then I enter \"380\" into input field number 3"

   phone = "091" + ('1'..'9').to_a.shuffle[0,7].join
   macro "Then I enter phone into input field number 4"
   macro "Then I touch the \"SignIn\" button"
   macro "And I wait until I see \"gridView\""
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
