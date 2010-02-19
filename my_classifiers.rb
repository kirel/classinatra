require 'classifiers'
require 'extractors'
require 'elastic_matcher'

include Classifiers

classifier :default do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r })
end

classifier :elastic do
  Classifiers::DistanceBasedClassifier.new(
    lambda { |strokes| strokes.first } *
    Preprocessors::Strokes::Concatenation.new *
    Preprocessors::Strokes::EquidistantPoints.new(:points => 30) *
    Preprocessors::Strokes::SizeNormalizer.new *
    Preprocessors::Strokes::RemoveDuplicatePoints.new *
    Preprocessors::JSONtoStrokes.new,
    ElasticMatcher.new(lambda { |v,w| (v-w).r }), # measure
    :limit => 50
  )
end