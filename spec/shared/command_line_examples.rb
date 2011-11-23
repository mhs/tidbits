shared_examples_for "running cleanly" do
  it "have a 0 exit status" do
    subject
    $?.exitstatus.should eq(0)
  end
end

shared_examples_for "running with help" do
  it "prints the help" do
    subject.should match(/^Usage:/)
  end
end

