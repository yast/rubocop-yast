
# mark features that were ported from Zombie Killer but do not work yet
Given(/^this gets implemented/) do
  pending
end

# inline code
Given(/^the original code is "(.*)"$/) do |original_code|
  @original_code = original_code
end

# multiline code passed via docstring
Given(/^the original code is$/) do |original_code|
  @original_code = original_code
end

When(/^the cop (.*) autocorrects it$/) do |name|
  @cop = RuboCop::Cop::Cop.all.find { |cop| cop.cop_name == name }.new
  @corrected = autocorrect_source(@cop, @original_code)
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

When(/^the cop (.*) checks it$/) do |name|
  @cop = RuboCop::Cop::Cop.all.find { |cop| cop.cop_name == name }.new
  inspect_source(@cop, @original_code)
end

Then(/^the code is found correct$/) do
  expect(@cop.offenses).to be_empty
end

Then(/^offense "(.*)" is found$/) do |offense|
  expect(@cop.offenses.first.message).to include(offense)
end
