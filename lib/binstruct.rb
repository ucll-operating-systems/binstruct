# frozen_string_literal: true

require_relative "binstruct/version"

module BinStruct
  class Error < StandardError; end

  module Types
    class Base
      def inspect
        "#{self.class.name}/#{size}"
      end
    end

    class Unsigned8 < Base
      def size
        1
      end

      def from_bytes(bytes)
        bytes.unpack('C').first
      end

      def to_bytes(value)
        [ value ]
      end
    end

    class Unsigned16 < Base
      def size
        2
      end

      def from_bytes(bytes)
        bytes.unpack('S<').first
      end

      def to_bytes(value)
        [ value ].pack('S<').unpack('C*')
      end
    end

    class Unsigned32 < Base
      def size
        4
      end

      def from_bytes(bytes)
        bytes.unpack('L<').first
      end

      def to_bytes(value)
        [ value ].pack('L<').unpack('C*')
      end
    end
  end

  def self.define_binstruct(&block)
    context = DefinitionContext.new
    context.instance_eval(&block)
    context.finalize
  end

  private
  class DefinitionContext
    def initialize
      @fields = []
    end

    def field(identifier, type)
      @fields << Field.new(identifier, type)
    end

    def u8
      Types::Unsigned8.new
    end

    def u16
      Types::Unsigned16.new
    end

    def u32
      Types::Unsigned32.new
    end

    def finalize
      BinaryStructDescription.new(@fields)
    end
  end


  Field = Struct.new :identifier, :type


  class BinaryStructDescription
    def initialize(fields)
      @fields = fields.dup.freeze
    end

    def fields
      @fields
    end

    def size
      @fields.map(&:type).map(&:size).sum
    end

    def offset(identifier)
      index = @fields.find_index { |field| field.identifier == identifier }
      @fields[0...index].map(&:type).map(&:size).sum
    end

    def create(buffer)
      raise Error, 'Buffer has wrong size' unless buffer.size == size

      BinaryStruct.new(self, buffer)
    end
  end

  class BinaryStruct
    def initialize(description, bytes)
      @description = description
      @bytes = bytes

      @description.fields.each do |field|
        offset = @description.offset field.identifier

        define_singleton_method field.identifier do
          string = @bytes[offset...offset+field.type.size].pack('C*')
          field.type.from_bytes(string)
        end

        define_singleton_method "#{field.identifier}=" do |value|
          bytes = field.type.to_bytes(value)
          offset = @description.offset field.identifier

          (0...bytes.size).each do |i|
            @bytes[offset + i] = bytes[i]
          end
        end
      end
    end

    attr_reader :description
  end
end
