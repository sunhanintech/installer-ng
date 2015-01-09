actions :enable, :disable

def initialize(*args)
  super
  @action = :enable  # Default action is enable
end

attribute :mod, :kind_of => String, :name_attribute => true  # This attribute is the name
