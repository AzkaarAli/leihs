module Json
  module FieldHelper

    def hash_for_field(field, with = nil)
      field.as_json
    end
  end
end
