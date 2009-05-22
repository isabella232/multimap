require 'multimap'

class NestedMultiMap < MultiMap
  def store(*args)
    value = args.pop
    key   = args.shift
    keys  = args

    raise ArgumentError, 'wrong number of arguments (1 for 2)' unless value

    if keys.empty?
      super(key, value)
    else
      update_container(key) do |container|
        container = self.class.new(container) if container.is_a?(default.class)
        container[*keys] = value
        container
      end
    end
  end
  alias_method :[]=, :store

  def <<(value)
    each_pair_list { |key, container| container << value }
    append_to_default_container!(value)
    nil
  end

  def [](*keys)
    result, i = self, 0
    while result.is_a?(self.class)
      result = result.hash_aref(keys[i])
      i += 1
    end
    result
  end

  def lists
    descendants = []
    each_list do |container|
      if container.respond_to?(:lists)
        container.lists.each do |descendant|
          descendants << descendant
        end
      else
        descendants << container
      end
    end
    descendants
  end

  private
    def append_to_default_container!(value)
      self.default = self.default.dup
      self.default << value
      self.default.freeze
    end
end

begin
  require 'nested_multimap_ext'
rescue LoadError
end
