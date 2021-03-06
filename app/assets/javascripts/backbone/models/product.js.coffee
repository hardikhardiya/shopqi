# 自定义集合中会用到
App.Models.Product = Backbone.Model.extend
  name: 'product'

  initialize: (args) ->
    #backbone.rails的initialize被覆盖，导致无法获取id，需要手动调用
    this.maybeUnwrap args
    this.with_options()
    # 保存商品后要重置选项集合
    this.bind 'change:options', this.with_options

  #重载，支持子实体
  toJSON : ->
    @unset 'id', silent: true
    @unset 'shop_id', silent: true
    attrs = @wrappedAttributes()
    #手动调用_clone，因为toJSON会加wraper
    if @options?
      options_attrs = @options.models.map (model) -> model.toJSON()['product_option']
      attrs['product']['options_attributes'] = options_attrs
    attrs

  #设置关联
  with_options: ->
    if @id? and @attributes.options
      #清除原有选项
      @last_options = @options
      if @last_options
        _(@last_options.models).each (model) ->
          model.view.remove()
      #@see http://documentcloud.github.com/backbone/#FAQ-nested
      @options = new App.Collections.ProductOptions
      @options.refresh @attributes.options
      this.unset 'options', silent: true
      #找出已删除的选项，用于更新款式选项值
      if @last_options
        options_size = @last_options.length
        removed_options = _(@last_options.models).select (model) ->
          model.attributes._destroy is '1'
        _(removed_options).each (option) ->
          position = option.attributes.position
          _(App.product_variants.models).each (variant) ->
            _(_.range(position, options_size)).each (i) ->
              attr = {}
              attr["option#{i}"] = variant.get("option#{i+1}")
              variant.set attr, silent: true
    this

  addedTo: (collection) ->
    self = this
    collection.detect (model) ->
      model.attributes.product_id == self.id

# 商品选项
App.Models.ProductOption = Backbone.Model.extend
  name: 'product_option'

  toJSON : ->
    @unset 'product_id', silent: true
    @unset 'first', silent: true
    @unset 'last', silent: true
    @wrappedAttributes()

# 商品款式
App.Models.ProductVariant = Backbone.Model.extend
  name: 'product_variant'

  toJSON: ->
    @unset 'id', silent: true
    @unset 'product_id', silent: true
    @unset 'shop_id', silent: true
    @wrappedAttributes()

  validate: (attrs) ->
    return unless attrs.option1? #没有修改option值则不校验
    self = this
    i = 1
    error = {}
    # 必填
    _(App.product.options.models).each (model) ->
      unless attrs["option#{i++}"]
        error["Basic Options#{model.attributes.name}"] = "Can not be empty!"
    # 唯一性
    exists = App.product_variants.find (variant) ->
      result = variant.id isnt self.id
      i = 1
      _(App.product.options.models).each ->
        attr = "option#{i++}"
        result = result and variant.attributes[attr] is attrs[attr]
      result
    if exists then error["基本选项"] = "已经存在!"
    error["价格"] = "不能为空!" unless attrs["price"] isnt '' # 价格、重量
    error["重量"] = "不能为空!" unless attrs["weight"] isnt ''

    #验证SKU是否超过限制
    if App.current_sku_size >= App.shop_sku_size
      error['商品SKU'] = "超过商店限制!"

    if _(error).size() is 0
      return
    else
      error

App.Collections.AvailableProducts = Backbone.Collection.extend
  model: App.Models.Product
  url: '/admin/available_products'

  initialize: ->
    self = this
    this.bind 'refresh', ->
      _(self.models).each (model) ->
        new App.Views.CustomCollection.AvailableProduct model: model

App.Collections.Products = Backbone.Collection.extend
  model: App.Models.Product

App.Collections.ProductOptions = Backbone.Collection.extend
  model: App.Models.ProductOption

  initialize: ->
    _.bindAll this, 'addOne', 'removeOne', 'showBtn'
    @bind 'add', @addOne
    @bind 'remove', @removeOne
    @bind 'all', @showBtn # 超过3个则隐藏[新增按钮]

  addOne: (model, collection) ->
    new App.Views.ProductOption.Edit model: model

  removeOne: (model, collection) ->
    model.view.remove()

  showBtn: (model, collection) ->
    if this.length >= 3
      $('#add-option-bt').hide()
    else
      $('#add-option-bt').show()


App.Collections.ProductVariants = Backbone.Collection.extend
  model: App.Models.ProductVariant

  url: ->
    "/admin/products/#{App.product.id}/variants"

  initialize: ->
    _.bindAll this, 'addOne'
    this.bind 'add', this.addOne

  addOne: (model, collection) ->
    msg '新增成功!'
    $('#new-variant-link').show()
    $('#new-variant').hide()
    new App.Views.Product.Show.Variant.Show model: model
    new App.Views.Product.Show.Variant.QuickSelect collection: collection
    new App.Views.ProductOption.Index collection: App.product.options

  # 所有款式的选项合集
  options: ->
    #return @data if @data
    @data = option1: [], option2: [], option3: []
    _(@models).each (model) =>
      i = 1
      _(@data).each (option, key) =>
        option.push model.attributes["option#{i++}"]
        @data[key] = _.uniq _.compact option
    @data
