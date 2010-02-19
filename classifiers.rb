require 'sample'

module Classifiers

  Hit = Struct.new :id, :score
    
  # classifiers
  
  class Base
    
    def classify data
      raise 'Abstract! Please implement!'
      # return Array of Hits
    end
    
    def train id, data
      raise 'Abstract! Please implement!'
    end
    
    # destroys training data - use with caution
    def reset!
      raise 'Abstract! Please implement!'
    end
    
  end
  
  # Distance based type 3 classifier
  class DistanceBasedClassifier < Base
        
    def initialize extractor, measure, options = {}
      @options = {
        :limit => 100
      }.update(options)
      @extractor = extractor
      @measure = measure
      @semaphore = Mutex.new # synchronize access to @samples
      reset!
    end
    
    # train the classifier
    def train id, data, sample_id = nil # sample_id is for caching purposes
      extracted = @extractor.call(data)
      synchronize do
        @samples << Sample.new(id, extracted)
      end
      true
    end

    def classify data, options = {}
      unknown = @extractor.call(data)
      # sort by distance and find minimal distance for each class
      minimal_distance_hash = synchronize do
        @samples.inject({}) do |minhash, sample|
          d = @measure.call(unknown, sample.data)
          minhash[sample.id] && minhash[sample.id] < d ? minhash : minhash.update(sample.id => d)
        end
      end
      ret = minimal_distance_hash.map { |id, dist| Hit.new id, dist }.sort_by{ |h| h.score }
      return ret
    end
    
    def reset!
      @samples = CappedContainer.new @options[:limit]
    end
    
    protected
    
    def synchronize &block
      @semaphore.synchronize &block
    end

  end # DistanceBasedClassifier
  
  @@classifier_blueprints = {}
  
  module_function
  
  def classifier key, &block
    @@classifier_blueprints[key] = proc &block
  end
  
  def [] key
    @@classifier_blueprints[key].call
  end
  

end