require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

require 'sample'
require 'classifiers'

shared_examples_for "all classifiers" do
  
  before do
    @data = 1
    @sample = Sample.new(:"1", 1)
  end
    
  it "should train a sample" do
    lambda { @classifier.train(@sample.id, @sample.data) }.should_not raise_error
  end
  
  describe "with some samples trained" do
    
    before do
      (1..10).each do |i|
        sample = Sample.new(:"#{i}", i)
        @classifier.train(sample.id, sample.data)
      end
    end
    
    it "should classify a new sample" do
      lambda { @classifier.classify(@data) }.should_not raise_error
    end

    it "should return results ordered by their score" do
      res = @classifier.classify(@data)
      # # mapping to hit[:score] as sort_by is not stable
      res.map { |hit| hit.score }.should === res.sort_by { |hit| hit.score }.map { |hit| hit.score }
    end
    
  end
  
end

describe Classifiers::DistanceBasedClassifier do

  before do
    @extractor = lambda { |i| i } # identity
    @measure = lambda { |i,j| (i - j).abs }
    @classifier = Classifiers::DistanceBasedClassifier.new @extractor, @measure
  end
  
  it_should_behave_like "all classifiers"
  
end

describe Classifiers::CombinedClassifier do
  
  before do
    @extractor = lambda { |i| i } # identity
    @measure = lambda { |i,j| (i - j).abs }
    @combiner = lambda { |a,b| a+b }
    @classifier = Classifiers::CombinedClassifier.new @combiner,
      Classifiers::DistanceBasedClassifier.new(@extractor, @measure),
      Classifiers::DistanceBasedClassifier.new(@extractor, @measure)
  end
  
  it_should_behave_like "all classifiers"
  
  it "should combine scores" do
    @measure = lambda { |i,j| 1 }
    @classifier = Classifiers::CombinedClassifier.new @combiner,
      Classifiers::DistanceBasedClassifier.new(@extractor, @measure),
      Classifiers::DistanceBasedClassifier.new(@extractor, @measure)
    @classifier.train :"1", 1
    @classifier.classify(1).first.score.should == 2
  end
  
end