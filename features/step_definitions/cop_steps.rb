
# inline code
Given(/^the original code is "(.*)"$/) do |original_code|
  @original_code = original_code
end

# multiline code passed via docstring
Given(/^the original code is$/) do |original_code|
  @original_code = original_code
end

When(/^I correct it using (.*) cop$/) do |cop|
  @cop = Object.const_get(cop).new
  @corrected = autocorrect_source(@cop, @original_code.split("\n"))
end

# inline code
Then(/^the code is converted to "(.*)"$/) do |expected_code|
  expect(@corrected).to eq(expected_code)
end

# multiline code passed via docstring
Then(/^the code is converted to$/) do |expected_code|
  expect(@corrected).to eq(expected_code)
end

Then(/^the code is unchanged$/) do
  expect(@corrected).to eq(@original_code)
end

When(/^I check it using (.*) cop$/) do |cop|
  @cop = Object.const_get(cop).new
  inspect_source(@cop, @original_code.split("\n"))
end

Then(/^the code is found correct$/) do
  expect(@cop.offenses).to be_empty
end

Then(/^offense "(.*)" is found$/) do |offense|
  expect(@cop.offenses.first.message).to include(offense)
end
