module Serial
  # A builder for building arrays. You most likely just want to look at the
  # public API methods in this class.
  class ArrayBuilder < Builder
    # @api private
    def initialize(context)
      @context = context
      @data = []
    end

    # @api public
    # Serializes a hash item in a collection.
    #
    # @example
    #   h.collection(…) do |l|
    #     l.element do |h|
    #       h.attribute(…)
    #     end
    #   end
    #
    # @yield [builder]
    # @yieldparam builder [HashBuilder]
    def element(value = :__not_used__, &block)
      if value == :__not_used__
        @data << HashBuilder.build(@context, &block)
      elsif not block
        @data << value
      else
        raise ArgumentError, "cannot pass both a block and an argument to `element`"
      end
    end

    # @api public
    # Serializes a collection in a collection.
    #
    # @example
    #   h.collection(…) do |l|
    #     l.collection do |l|
    #       l.element { … }
    #     end
    #   end
    #
    # @yield [builder]
    # @yieldparam builder [ArrayBuilder]
    def collection(&block)
      @data << ArrayBuilder.build(@context, &block)
    end
  end
end
