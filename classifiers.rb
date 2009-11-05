require 'decision_tree' # TODO autoload

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
    
  end
  
  class KnnClassifier < Base
        
    def initialize extractor, measure, options = {}
      options = {
        :k => 5,
        :limit => 100
      }.update(options)
      @k = options[:k] 
      @extractor = extractor
      @measure = measure
      @samples = CappedContainer.new options[:limit] # TODO add to options
      @semaphore = Mutex.new # synchronize access to @samples
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
      # use nearest neighbour classification
      # sort by distance and find minimal distance for each class
      minimal_distance_hash = {}
      sorted = synchronize do
        # puts @samples.size
        # i = 0
        @samples.sort_by do |sample|
          # puts "**** Vergleiche"
          d = @measure.call(unknown, sample.data)
          minimal_distance_hash[sample.id] = d if (!minimal_distance_hash[sample.id]) || (minimal_distance_hash[sample.id] > d)
          # puts "Abstand #{d}"
          # if d.nan?
          #   puts "-Unbekannt- #{unknown.inspect}"
          #   puts "-Muster- #{sample.inspect}"
          # end
          # puts (i += 1)
          d
        end
      end
      neighbours = Hash.new { |h,v| h[v] = 0 } # counting classes of neighbours
      # @k is number of best matches we want in the list
      while (!sorted.empty?) && (neighbours.size < @k)
        sample = sorted.shift # next nearest sample to f
        neighbours[sample.id] += 1 # counting neighbours of that class
      end
      max_nearest_neighbours_distance = neighbours.map { |id, _| minimal_distance_hash[id] }.max
      # TODO explain
      computed_neighbour_distance = {}
      neighbours.each { |id, num| computed_neighbour_distance[id] = max_nearest_neighbours_distance.to_f/num }
      minimal_distance_hash.update(computed_neighbour_distance)
      # FIXME this feels slow
      ret = minimal_distance_hash.map { |id, dist| Hit.new id, dist }.sort_by{ |h| h.score }
      # limit and skip shuld be done in the app
      # ret = ret[options[:skip] || 0, options[:limit] || ret.size] if [:limit, :skip].any? { |k| options[k] }
      return ret
    end
    
    protected
    
    def synchronize &block
      @semaphore.synchronize &block
    end

  end # KnnClassifier
  
  class DCPruningKnnClassifier < KnnClassifier
        
    def initialize extractor, measure, deciders, options = {}
      options = {
        :k => 5,
        :limit => 100
      }.update(options)
      @k = options[:k] 
      @extractor = extractor
      @measure = measure
      @tree = DecisionTree.new deciders, options[:limit]
      @semaphore = Mutex.new
    end
    
    def train id, data, sample_id = nil
      synchronize do
        @tree << Sample.new(id, @extractor.call(data), sample_id.to_s)
      end
      true
    end
    
    def classify data, options = {}
      synchronize do
        @samples = @tree.call data
      end
      super data, options
    end
    
  end
  
  @@classifier_blueprints = {}
  
  module_function
  
  def classifier key, &block
    @@classifier_blueprints[key] = proc &block
  end
  
  def [] key
    @@classifier_blueprints[key].call
  end
  

end