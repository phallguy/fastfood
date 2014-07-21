module Fastfood::Extensions::DirtyTrackingHash

  def self.enable_dirty_tracking( hash )
    def hash.dirty?; @_dirty end
    def hash.clean!
      @_dirty = false
      self
    end
    def hash.dirty!
      @_dirty = true
      self
    end

    def hash.[]=( key, value ); dirty!; super key, _dirty_tracking_value( value ) end
    def hash.store( key, value ); dirty!; super key, _dirty_tracking_value( value ) end

    def hash.clear( *args ); dirty!; super end
    def hash.keep_if( *args ); dirty!; super end
    def hash.delete( *args ); dirty!; super end
    def hash.reject!( *args ); dirty!; super end

    def hash.update( other_hash ); dirty!; super key, _dirty_tracking_value( other_hash ) end
    def hash.replace( other_hash ); dirty!; super key, _dirty_tracking_value( other_hash ) end
    def hash.merge!( other_hash ); dirty!; super key, _dirty_tracking_value( other_hash ) end
  end

  def initialize( *args )
    Fastfood::Extensions::DirtyTrackingHash.enable_dirty_tracking( self )
    super
  end

  private

    def _dirty_tracking_value( value )
      if value.is_a? Hash
        Fastfood::Extensions::DirtyTrackingHash.enable_dirty_tracking( value ) unless value.respond_to? :dirty?
      end

      value
    end

end
