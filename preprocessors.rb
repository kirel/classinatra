require 'matrix'
require 'math'
require 'extractors'
require 'utilities'

module Preprocessors

  class JSONtoStrokes

    include Lambdalike

    def call json
      JSON(json).map { |stroke| stroke.map { |point| Vector[point['x'], point['y']] }}
    end

  end

  module Strokes

    # TODO class FitInside
    #   DEFAULT_OPTIONS = { :x => 0.0..1.0, :y => 0.0..1.0 }
    #   def call strokes

    # TODO class LineDensity
    
    class Concatenation
      include Lambdalike
      def call strokes
        [strokes.sum]
      end
    end
    
    class RemoveDuplicatePoints
      include Lambdalike
      def call strokes
        strokes.map do |stroke|
          stroke.rest.inject([stroke.first]) do |newstroke, point|
            point != newstroke.last ? newstroke << point : newstroke
          end
        end
      end
    end

    class EquidistantPoints
      
      include Lambdalike

      DEFAULT_OPTIONS = { :distance => 0.01 }

      def initialize options = {}
        @options = DEFAULT_OPTIONS.update(options)
      end

      def call strokes
        if @options[:points] # points takes precedence over distance
          length = strokes.sum do |stroke|
            stroke.each_cons(2).reduce(0.0) { |l, vecs| l + (vecs.last - vecs.first).r }
          end
          distance = length/@options[:points]
        else
          distance = @options[:distance]
        end
        strokes.map do |stroke|
          # convert to equidistant point distribution
          equidistant_stroke = [stroke.first] # need first point anyway
          distance_left = distance
          previous = nil
          stroke.each do |point|
            if previous
              p = previous
              n = point
              v = n - p
              norm = v.r # FIXME might be zero
              # add new points
              while norm > distance_left
                p = p + v * (distance_left/norm)
                previous = p
                equidistant_stroke << previous
                distance_left = distance
                v = n - p
                norm = v.r            
              end
              distance_left -= norm # NOTE this does not distribute equidistantly - exact solution needs square computations
              previous = point
            else
              previous = point
            end
          end # stroke.each
          equidistant_stroke            
        end
      end

    end # class EquidistantPoints
    
    class DominantPoints
      
      include Lambdalike
      
      def initialize threshold = (2.0/24.0)*Math::PI # 15 rad
        @threshold = threshold
      end

      def call strokes
        RemoveDuplicatePoints.new.call(strokes).map do |stroke|
          if stroke.size < 3
            stroke
          else
            s = []
            points = stroke.each
            s << p = points.next # always add first point
            # current and next point are different as we already removed duplicate points
            c = points.next
            n = points.next
            loop do
              # check angle between s->c->n ~> v1, v2
              v1 = c - p
              v2 = n - c
              cosalpha = v1.inner_product(v2)/(v1.r*v2.r)
              raise "You really screwed up!" if cosalpha.nan?
              # workaround for acos argument aut of domain
              cosalpha = [[-1.0, cosalpha].max, 1.0].min
              alpha = Math::acos(cosalpha)
              if alpha > @threshold
                # add the point c
                s << p = c
              end # else drop it
              c = n
              # find next point that is different from current
              n = points.next until n != c
            end
            s << n unless n == s.last
          end
        end
      end # call
      
      # def call strokes # cool version
      #   strokes.map do |stroke|
      #     if stroke.size < 3
      #       stroke
      #     else
      #       # use only interators!
              # each_cons etc
      #     end
      #   end
      # end # call cool version
      
    end

    class SizeNormalizer
      
      include Lambdalike

      # TODO options

      def call strokes
        left, right, top, bottom = Extractors::Strokes::BoundingBox.new.call(strokes)

        # TODO push this into a preprocessor
        # computations for next step
        height = top - bottom
        width = right - left
        ratio = width/height
        long, short = ratio > 1 ? [width, height] : [height, width]
        offset = case
        when long.zero? # all points in one spot
          Vector[0.5, 0.5]
        when ratio > 1
          Vector[0.0, (1.0 - short/long)/2.0]
        else # ratio <= 1
          Vector[(1.0 - short/long)/2.0, 0.0]
        end

        # move left and bottom to zero, scale to fit and then center
        strokes.map do |stroke|
          stroke.map do |point|
            if long.zero? # all points in one spot
              point - Vector[left, bottom] + offset
            else
              ((point - Vector[left, bottom]) * (1.0/long)) + offset
            end
          end
        end
      end

    end

  end # module Strokes

end # module Preprocessors