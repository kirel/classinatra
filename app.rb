require 'json'
require 'sinatra'
require 'matrix'
require 'my_classifiers'

CLASSIFIER = Classifiers[:default]
#CLASSIFIER = Classifiers[:dcelastic]

post '/train/:id' do
  begin
    CLASSIFIER.train params[:id].to_sym, request.body.read
  #rescue
  end
  halt 200, JSON(:message => "Symbol was successfully trained.")
end

post '/classify' do
  hits = CLASSIFIER.classify request.body.read
  JSON hits.map { |hit| { :id => hit.id.to_s, :score => hit.score} }
end