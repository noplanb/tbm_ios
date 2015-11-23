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


# I can see /^drawer "([^”]*)"$/ do |type|

# frame = query("drawerView").first["frame"]
# drawerX = Integer(frame[/{(.), (.)}, {(.), (.)}/,1].split("{"")[1])

# frame = query("gridView").first["frame"]
# gridWidth = Integer(frame[/{(.), (.)}, {(.), (.)}/,2].split("{")[2])

# if type == "opened"
# 	screenshot_and_raise "Drawer expected to be #{type}:" if(drawerX < gridWidth)	
# else 
# 	screenshot_and_raise "Drawer expected to be #{type}:" if(drawerX =< gridWidth)
# end

# end
