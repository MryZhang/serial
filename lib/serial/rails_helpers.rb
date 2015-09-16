module Serial
  # Helpers for using Serial with Rails.
  module RailsHelpers
    # Find the serializer for `model` and serialize it in the context of self.
    #
    # @example serializing a single object
    #   render json: { person: serialize(Person.first) }
    #
    # @example serializing multiple objects
    #   render json: { people: serialize(Person.all) }
    #
    # @example serializing with explicit context
    #   render json: { people: serialize(presenter, Person.all) }
    #
    # @example serializing with explicit serializer
    #   render json: { people: serialize(Person.all, &my_serializer) }
    #
    # @param context [#instance_exec]
    # @param model [#model_name, #each?]
    def serialize(context = self, model, &serializer)
      serializer &&= Serializer.new(&serializer)
      serializer ||= "#{model.model_name}Serializer".constantize

      if model.respond_to?(:map)
        serializer.map(context, model)
      else
        serializer.call(context, model)
      end
    end
  end
end
