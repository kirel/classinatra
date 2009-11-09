require 'json'
require 'sinatra'
require 'matrix'
require 'my_classifiers'

CLASSIFIER = Classifiers[ENV['classifier'] && ENV['classifier'].to_sym || :default]
#CLASSIFIER = Classifiers[:dcelastic]

counts = Hash.new { |h,k| h[k] = 0 }

get '/' do
  JSON :counts => counts
end

post '/train/:id' do
  begin
    CLASSIFIER.train params[:id].to_sym, request.body.read
  #rescue
  end
  counts[params[:id].to_sym] += 1
  halt 200, JSON(:message => "Symbol was successfully trained.")
end

post '/classify' do
  hits = CLASSIFIER.classify request.body.read
  JSON hits.map { |hit| { :id => hit.id.to_s, :score => hit.score} }
end