App.Views.Domain.Show = Backbone.View.extend
  tagName: 'tr'

  events:
    "click a.btn": "make_primary"
    "change #shop_force_domain": "redirect" # 重定向
    "click .del": "destroy"

  initialize: ->
    self = this
    this.render()
    $('#domains > .items').append @el
    @model.bind 'change:primary', -> self.render()
    if @model.get('is_myshopqi?') # 主域名被删除，则官方子域名重新设置为主域名
      @collection.bind 'remove', (model) ->
        self.model.set primary:true, silent: true if model.get('primary')
        self.render()

  render: ->
    template = Handlebars.compile $('#domain-item').html()
    attrs = _.clone @model.attributes
    attrs['is_myshopqi'] = attrs['is_myshopqi?']
    $(@el).html template attrs
    $(@el).addClass 'primary' if @model.get('primary')
    this.check_dns()

  check_dns: ->
    self = this
    $.get "/admin/domains/#{@model.id}/check_dns", (data) ->
      message = if data is 'ok' then '成功' else $('#dns-wiki-item').html()
      self.$('.dns-check').html message

  make_primary: ->
    self = this
    primary_domain = @collection.detect (model) -> model.get('primary')
    $.post "/admin/domains/#{@model.id}/make_primary", _method: 'put', (data) ->
      primary_domain.set primary: false
      self.model.set primary: true
    false

  redirect: ->
    force_domain = $('#shop_force_domain').attr('checked') is 'checked'
    @model.unset 'is_myshopqi?', silent: true # 一定要先取消临时属性
    @model.save force_domain: force_domain
    false

  destroy: ->
    self = this
    if confirm 'Are you sure you want to delete it'
      @model.destroy
        success: (model, response) ->
          self.remove()
          self.collection.remove self.model
          msg 'Deleted successfully!'
    false
