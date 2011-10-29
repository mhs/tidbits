Given /^"([^\"]*)" is a directory$/ do |dirname|
  FileUtils.mkdir_p dirname
end

When /^I execute:$/ do |pystring|
  `#{pystring.to_s}`
end

When /^I execute and capture:$/ do |pystring|
  @captured_output = `#{pystring.to_s}`
end

Then /^the captured output should show me I.m in the "([^\"]+)" directory$/ do |dirname|
  @captured_output.chomp.should == File.expand_path(dirname)
end

Then /^the captured output should not contain "([^"]*)"$/ do |output|
  @captured_output.chomp.should_not =~ /#{output}/
end

Then /^the captured output should be "([^"]*)"$/ do |output|
  @captured_output.chomp.should == output
end

