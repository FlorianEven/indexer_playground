class Indexer
  DEFAULT_PARAMS = {
    paginate: {
      page: 1,
      per_page: 100,
    },
    filters: [],
    order: {
      key: "id",
      dir: "asc"
    }
  }

  def initialize(params = DEFAULT_PARAMS)
    @source = nil
    @rows = []

    @filter_param = params[:filters]
    @order_param = params[:order]
    @paginate = params[:paginate]

    call
  end

  def result
    @source = @source.offset(@paginate[:per_page] * (@paginate[:page] - 1)).limit(@paginate[:per_page])

    @source.map do |source_item|
      mapped_item = {}

      @rows.each do |row|
        @value_row = row[:name]
        mapped_item[row[:name]] = row[:value].call(source_item)
      end

      mapped_item
    end
  end

  def as_json
    {
      page: @paginate[:page],
      per_page: @paginate[:per_page],
      items: result
    }.to_json
  end

  private

  def relation
    @source = yield
  end

  def column(name)
    @row = { name: name }
    @filter = nil
    @order = nil

    setup_default_column_arguments

    yield if block_given?

    @rows << @row

    execute_order(name)
    execute_filter(name)
  end

  def value(&block)
    @row[:value] = block
  end

  def order(&block)
    @order = block
  end

  def filter(&block)
    @filter = block
  end

  def setup_default_column_arguments
    value do |source_item|
      source_item.send(@value_row.to_s)
    end

    order do |source, dir|
      source.order(Sequel.send(dir, @order_param[:key].to_sym))
    end

    filter do |source, filter_value|
      source.where(@row[:name] => filter_value)
    end
  end

  def execute_order(name)
    if @order_param[:key].to_s == name.to_s
      @source = @order.call(@source, @order_param[:dir].to_s.downcase)
    end
  end

  def execute_filter(name)
    if filter_item = @filter_param.find { |item| item[:key].to_s == name.to_s }
      @source = @filter.call(@source, filter_item[:value])
    end
  end
end
