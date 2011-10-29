require File.join(File.dirname(__FILE__), '../../lib/aliasdir/aliases')
require 'rubygems'
require 'fileutils'
require 'rspec'
require 'rspec/autorun'

Aliases.class_eval do
  remove_const :FILE
  const_set :FILE, Etc.getpwuid.dir + '/.aliasdir_spec'
  at_exit { FileUtils.rm(Aliases::FILE) if File.exists?(Aliases::FILE) }
end

describe Aliases, '#[]= - aliasing a directory' do
  it 'should store the aliases directory in the Aliases::FILE' do
    Aliases['test'] = '/the/test/directory'
    YAML.load(IO.read(Aliases::FILE))['test'].should == '/the/test/directory'
  end
  
  it 'should be able to overwrite an alias with a new directory in the Aliases::FILE' do
    Aliases['test'] = '/the/test/directory'
    Aliases['test'] = '/a/new/cool/place'
    YAML.load(IO.read(Aliases::FILE))['test'].should == '/a/new/cool/place'
  end
  
  it 'should be able to store multiple aliases in the Aliases::FILE' do
    Aliases['test1'] = '1'
    Aliases['test2'] = '2'
    aliases = YAML.load(IO.read(Aliases::FILE))
    aliases['test1'].should == '1'
    aliases['test2'].should == '2'
  end
  
  it 'should be able to store directory aliases with spaces escaped' do
    Aliases['test'] = '/the/test directory'
    YAML.load(IO.read(Aliases::FILE))['test'].should == '/the/test\ directory'
  end

  it 'should be able to store directory aliases with exclamation points escaped' do
    Aliases['test'] = '/the/test!directory'
    YAML.load(IO.read(Aliases::FILE))['test'].should == '/the/test\!directory'
  end

  it 'should be able to store directory aliases with question marks escaped' do
    Aliases['test'] = '/the/test?directory'
    YAML.load(IO.read(Aliases::FILE))['test'].should == '/the/test\?directory'
  end

end

describe Aliases, '#[] - reading an an alias' do
  it 'should be able to return the aliased target path' do
    Aliases['foo'] = 'bar'
    Aliases['foo'].should == 'bar'
  end
end

describe Aliases, '#dump - dumping aliases for shell execution' do
  before(:each) do
    FileUtils.rm(Aliases::FILE)
    Aliases['blam'] = 'bar'
    Aliases['foo'] = 'baz'
  end
  
  it 'should be able to return the appropriate string of aliases for bash shell execution' do
    Aliases.dump(:shell).should == %|alias blam='cd bar';alias foo='cd baz'|
  end
end

describe Aliases, '#dump - dumping aliases for human readability' do
  before(:each) do
    FileUtils.rm(Aliases::FILE)
    Aliases['blam'] = 'bar'
    Aliases['foo'] = 'baz'
  end
  
  it 'should be able to return the appropriate string of aliases for human readability' do
    Aliases.dump(:pretty).should == %|alias blam='cd bar'\nalias foo='cd baz'|
  end
end
