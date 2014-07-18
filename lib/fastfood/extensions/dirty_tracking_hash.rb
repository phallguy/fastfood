module Fastfood::Extensions::DirtyTrackingHash
  # Indicates if the hash has changed since it was loaded.
  def dirty?
    @_dirty
  end

  # Marks the hash as clean for dirty tracking.
  def clean!
    @_dirty = false
    self
  end

  # Marks the bucket as dirty.
  def dirty!
    @_dirty = true
    self
  end

  %w{ clear keep_if delete reject! }.each do |method|
    module_eval %{
      def #{method}( *args )
        dirty!
        super
      end
    }
  end

  %w{ []= store }.each do |method|
    module_eval %{
      def #{method}( key, value )
        dirty!
        super key, _dirty_tracking_value( value )
      end
    }
  end

  %w{ update replace merge! }.each do |method|
    module_eval %{
      def #{method}( other_hash )
        dirty!
        super key, Hash[ other_hash.map{|k,v| [k, _dirty_tracking_value( v )] } ]
      end
    }
  end



  private
    def _dirty_tracking_value( value )
      if value.is_a? Hash
        Fastfood::Extensions::DirtyTrackingHash::Hash.new( value )
      else
        value
      end
    end

  class Hash < Hashie::Mash

    include Fastfood::Extensions::DirtyTrackingHash
  end

end
