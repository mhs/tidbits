describe "bin/grab" do
  before { Dir.chdir bindir }
  after  { Dir.chdir pwd }
  
  subject { `#{command}` }
  let(:pwd){ File.expand_path File.dirname(__FILE__) }
  let(:bindir){ File.join pwd, "../../bin" }

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
  
  context "running with -h" do
    let(:command){ "grab -h" }
    it_should_behave_like "running with help"
    it_should_behave_like "running cleanly"
  end

  context "running with --help" do
    let(:command){ "grab --help" }
    it_should_behave_like "running with help"
    it_should_behave_like "running cleanly"
  end
  
  context "running without any arguments or input" do
    let(:command){ "grab" }
    
    it_should_behave_like "running with help"

    it "have a 1 exit status" do
      subject
      $?.exitstatus.should eq(1)
    end
  end

  describe "redirecting another command's output through grab" do
    subject { `#{command}` }
    let(:command){ "echo 'a b c\nd e f' | grab 1" }
    
    it_should_behave_like "running cleanly"
    
    context "the first column" do
      it "outputs the 1st column of output for each line of output" do
        subject.should eq("a\nd\n")
      end 
    end

    context "the second column" do
      let(:command){ "echo 'a b c\nd e f' | grab 2" }
      
      it "outputs the 2nd column of output for each line of output" do
        subject.should eq("b\ne\n")
      end 
    end

    context "the third column" do
      let(:command){ "echo 'a b c\nd e f' | grab 3" }

      it "outputs the 3rd column of output for each line of output" do
        subject.should eq("c\nf\n")
      end 
    end
  end

end

