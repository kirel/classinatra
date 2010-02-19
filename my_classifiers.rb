require 'classifiers'
require 'extractors'
require 'elastic_matcher'

include Classifiers

classifier :default do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r })
end

classifier :k1 do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 1)
end

classifier :k2 do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 2)
end

classifier :k10 do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 10)
end

classifier :k25 do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 25)
end

classifier :ten do
  DistanceBasedClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 10, :limit => 10)
end

classifier :elastic do
  Classifiers::DistanceBasedClassifier.new(
    lambda { |strokes| strokes.first } *
    Preprocessors::Strokes::Concatenation.new *
    Preprocessors::Strokes::DominantPoints.new *
    Preprocessors::Strokes::EquidistantPoints.new(:points => 30) *
    Preprocessors::Strokes::SizeNormalizer.new *
    Preprocessors::JSONtoStrokes.new,
    ElasticMatcher.new(lambda { |v,w| (v-w).r }), # measure
    :k => 5,
    :limit => 50
  )
end