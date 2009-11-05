require 'classifiers'
require 'extractors'
require 'elastic_matcher'

include Classifiers

classifier :default do
  KnnClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r })
end

classifier :largek do
  KnnClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 25)
end

classifier :ten do
  KnnClassifier.new(Extractors::Strokes::Features.new * Preprocessors::JSONtoStrokes.new, lambda { |v,w| (v-w).r }, :k => 10, :limit => 10)
end

classifier :tenelastic do
  Classifiers::KnnClassifier.new(
    Preprocessors::Strokes::EquidistantPoints.new(:distance => 0.3) *
    Preprocessors::Strokes::SizeNormalizer.new *
    Preprocessors::JSONtoStrokes.new,
    MultiElasticMatcher, # measure
    :k => 6, # to bubble down impostors
    :limit => 10
  )
end

classifier :dcelastic do
  Classifiers::DCPruningKnnClassifier.new(
    Preprocessors::Strokes::EquidistantPoints.new(:distance => 0.3) *
    Preprocessors::Strokes::SizeNormalizer.new *
    Preprocessors::JSONtoStrokes.new,
    MultiElasticMatcher,
    [lambda { |i| i.size }, Extractors::Strokes::AspectRatio.new(4)],
    :k => 6, # to bubble down impostors
    :limit => 10
  )
end
