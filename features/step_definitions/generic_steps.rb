Given /this is a pending scenario/ do
  pending
end

Given /^I am working on the mobile interface$/ do
  @mobile_interface = true
end

Then /the badge should show (.*)/ do |number|
  badge = -1
  xpath= "//span[@id='badge_count']"

  if response.respond_to? :selenium
    response.should have_xpath(xpath) 
    badge = response.selenium.get_text("xpath=#{xpath}").to_i
  else
    response.should have_xpath(xpath) do |node|
      badge = node.first.content.to_i
    end
  end

  badge.should == number.to_i
end

Then /^I should see the empty message in the deferred container$/ do
  wait_for :timeout => 5 do
    selenium.is_visible("xpath=//div[@id='tickler']//div[@id='tickler-empty-nd']")
  end
end

Then /^I should see the empty tickler message$/ do
  wait_for :timeout => 5 do
    selenium.is_visible("xpath=//div[@id='tickler-empty-nd']")
  end
end

Then /^I should not see the empty tickler message$/ do
  wait_for :timeout => 5 do
    !selenium.is_visible("xpath=//div[@id='tickler-empty-nd']")
  end
end

Then /^I should see an error flash message saying "([^"]*)"$/ do |message|
  xpath = "//div[@id='message_holder']/h4[@id='flash']"
  text = response.selenium.get_text("xpath=#{xpath}")
  text.should == message
end
