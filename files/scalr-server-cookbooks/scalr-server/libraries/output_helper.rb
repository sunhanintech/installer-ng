# This helper adds a "description" attribute to all built-in resources to help making output more human readable

class Chef
  class Resource

    def description(arg=nil)
      set_or_return(:description, arg, :regex => /^.*$/)
    end

  end
end
