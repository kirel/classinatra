require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

require 'my_classifiers'

describe "my classifiers" do
  before do
    @sample = JSON([[{:x => 1, :y => 1}]])
  end
  
  it "default works" do
    @cla = Classifiers[:default]
    @cla.train :label, @sample
    @cla.classify(@sample).should == [Hit.new(:label, 0.0)]
  end
  
end