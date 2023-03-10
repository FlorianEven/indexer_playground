require "sequel"

DB = Sequel.sqlite

DB.create_table :items do
  primary_key :id
  String :name
  Float :price
end
