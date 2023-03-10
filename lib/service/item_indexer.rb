class ItemIndexer < Indexer
  def call
    relation do
      Item.where{price > 1}
    end

    column :name do
      value do |source_item|
        source_item.name
      end

      filter do |source, filter_value|
        source.where(name: filter_value)
      end

      order do |source, dir|
        source.order(Sequel.send(dir, :name))
      end
    end

    column :price
  end
end
