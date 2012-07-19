module ClassInheritable
  class Array

    DEFAULT_ARRAY_NAME = 'class_inheritable_array'

    attr_reader :caller_class
    def initialize( _caller_class )
      raise ArgumentError, "invalid calling class" if _caller_class <= ClassInheritable::Array
      @caller_class = _caller_class
    end

    def attach( options = {} )
      define_writer_for( caller_class, options )
      define_appender_for( caller_class, options )
      define_reader_for( caller_class, options )
      define_instance_reader_for( caller_class, options )
      _init( options )
    end

    class << self
      # Factory method:
      def attach( options = {}, &block )
        caller_class = options[ :to ]
        caller_class ||= calling_object( &block ) if block_given?
        raise ArgumentError, ":to or block required" unless caller_class
        new( caller_class ).attach( options )
      end

      # Class methods
      def array_of_parent( child, options = {} )
        array = array_name( options )
        parent = child.send( :superclass )
        return [] unless parent.respond_to?( array )

        parent.send( array ) || []
      end

      def writer_name( options = {} )
        options[ :writer_name ] || "#{array_name( options )}="
      end

      def appender_name( options = {} )
        options[ :appender_name ] || "append_#{array_name( options )}"
      end

      def instance_reader_name( options = {} )
        options[ :instance_reader_name ] || reader_name( options )
      end

      def reader_name( options = {} )
        options[ :reader_name ] || array_name( options )
      end

      def array_name( options = {} )
        options[ :as ] || DEFAULT_ARRAY_NAME
      end

      def eigenclass_for( base )
        class << base; self; end
      end

      def calling_object( &block )
        eval 'self', block.send(:binding)
      end
    end


    private

    def _init( options = {} )
      reader = ClassInheritable::Array.reader_name( options )
      caller_class.send( reader )
      self
    end

    def define_writer_for( base, options = {} )
      eigenclass = ClassInheritable::Array.eigenclass_for( base )
      writer = ClassInheritable::Array.writer_name( options )
      array = ClassInheritable::Array.array_name( options )
      eigenclass.class_eval do
        define_method( "#{writer}" ) do |entries|
          entries = [ entries ] unless entries.is_a?( ::Array )
          instance_variable_set( "@#{array}", entries )
        end
      end
    end

    def define_appender_for( base, options = {} )
      eigenclass = ClassInheritable::Array.eigenclass_for( base )
      appender = ClassInheritable::Array.appender_name( options )
      reader = ClassInheritable::Array.reader_name( options )
      writer = ClassInheritable::Array.writer_name( options )
      eigenclass.class_eval do
        define_method( "#{appender}" ) do |entries|
          entries = [ entries ] unless entries.is_a?( ::Array )
          self.send( writer, self.send( reader ) | entries )
        end
      end
    end

    def define_instance_reader_for( base, options = {} )
      reader = ClassInheritable::Array.instance_reader_name( options )
      base.class_eval do
        define_method( "#{reader}" ) do
          self.class.send( "#{reader}" )
        end
      end
    end

    def define_reader_for( base, options = {} )
      eigenclass = ClassInheritable::Array.eigenclass_for( base )
      array = ClassInheritable::Array.array_name( options )
      reader = ClassInheritable::Array.reader_name( options )
      eigenclass.class_eval do
        define_method( "#{reader}" ) do
          unless instance_variable_get( "@#{array}" )
            instance_variable_set(
              "@#{array}", [] |
              ClassInheritable::Array.array_of_parent( self, options )
            )
          end
          instance_variable_get( "@#{array}" )
        end
      end
    end
  end
end
