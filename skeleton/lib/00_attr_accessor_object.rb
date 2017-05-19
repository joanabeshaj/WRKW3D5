class AttrAccessorObject

  def self.my_attr_accessor(*method_names)
    method_names.each do |m_name|

      define_method(m_name) do
        instance_variable_get("@#{m_name}")
      end

      define_method("#{m_name}=") do |value|
        instance_variable_set("@#{m_name}", value)
      end

    end

  end
end
