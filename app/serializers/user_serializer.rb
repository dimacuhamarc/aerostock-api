class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :first_name, :last_name, :employee_id
end
