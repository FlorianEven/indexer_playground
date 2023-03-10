require "json"
require "./database"
require "./lib/models/item"
require "./lib/helper/indexer"

require "./lib/service/item_indexer"

Item.create(name: "foo", price: 3.5)
Item.create(name: "bar", price: 2)

params = {
  paginate: {
    page: 2,
    per_page: 1,
  },
  filters: [
  ],
  order: {
    key: "name",
    dir: "asc"
  }
}

pp ItemIndexer.new(params).as_json
