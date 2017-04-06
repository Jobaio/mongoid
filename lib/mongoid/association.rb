require 'mongoid/association/accessors'
require 'mongoid/association/builders'
require 'mongoid/association/bindable'
require 'mongoid/association/depending'
require 'mongoid/association/macros'
require 'mongoid/association/proxy'
require 'mongoid/association/touchable'

require 'mongoid/association/many'
require 'mongoid/association/one'
require 'mongoid/association/macros'
require 'mongoid/association/relatable'

require 'mongoid/association/nested'
require 'mongoid/association/referenced'
require 'mongoid/association/embedded'

require 'mongoid/association/reflections'
require 'mongoid/association/eager_loadable'

module Mongoid
  module Association
    extend ActiveSupport::Concern
    include Embedded::Cyclic
    include Referenced::AutoSave
    include Referenced::CounterCache
    include Referenced::Syncable
    include Accessors
    include Depending
    include Builders
    include Macros
    include Reflections

    attr_accessor :__association
    alias :relation_association :__association

    included do
      class_attribute :polymorphic
      self.polymorphic = false
    end

    # Determine if the document itself is embedded in another document via the
    # proper channels. (If it has a parent document.)
    #
    # @example Is the document embedded?
    #   address.embedded?
    #
    # @return [ true, false ] True if the document has a parent document.
    #
    # @since 2.0.0.rc.1
    def embedded?
      @embedded ||= (cyclic ? _parent.present? : self.class.embedded?)
    end

    # Determine if the document is part of an embeds_many relation.
    #
    # @example Is the document in an embeds many?
    #   address.embedded_many?
    #
    # @return [ true, false ] True if in an embeds many.
    #
    # @since 2.0.0.rc.1
    def embedded_many?
      __association && __association.macro == :embeds_many
    end

    # Determine if the document is part of an embeds_one relation.
    #
    # @example Is the document in an embeds one?
    #   address.embedded_one?
    #
    # @return [ true, false ] True if in an embeds one.
    #
    # @since 2.0.0.rc.1
    def embedded_one?
      __association && __association.macro == :embeds_one
    end

    # Get the association name for this document. If no association was defined
    # will raise an error.
    #
    # @example Get the association name.
    #   document.association_name
    #
    # @raise [ Errors::NoMetadata ] If no association metadata is present.
    #
    # @return [ Symbol ] The association name.
    #
    # @since 3.0.0
    def association_name
      raise Errors::NoMetadata.new(self.class.name) unless __association
      __association.name
    end

    # Determine if the document is part of an references_many relation.
    #
    # @example Is the document in a references many?
    #   post.referenced_many?
    #
    # @return [ true, false ] True if in a references many.
    #
    # @since 2.0.0.rc.1
    def referenced_many?
      __association && __association.macro == :has_many
    end

    # Determine if the document is part of an references_one relation.
    #
    # @example Is the document in a references one?
    #   address.referenced_one?
    #
    # @return [ true, false ] True if in a references one.
    #
    # @since 2.0.0.rc.1
    def referenced_one?
      __association && __association.macro == :has_one
    end

    # Convenience method for iterating through the loaded relations and
    # reloading them.
    #
    # @example Reload the relations.
    #   document.reload_relations
    #
    # @return [ Hash ] The association metadata.
    #
    # @since 2.1.6
    def reload_relations
      relations.each_pair do |name, meta|
        if instance_variable_defined?("@_#{name}")
          if _parent.nil? || instance_variable_get("@_#{name}") != _parent
            remove_instance_variable("@_#{name}")
          end
        end
      end
    end
  end
end