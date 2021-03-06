App.Views.Payment.Index = Backbone.View.extend
  el: '#main'

  events:
    'change #select_custom_payment_method' : 'select_method'
    'click #checkout' : 'change_checkout_config'
    'submit form#new_custom_payment' : 'save'

  initialize: ->
    new App.Views.Payment.Online el: '#payment_alipay', model: App.payment_alipay # 支付宝
    new App.Views.Payment.Online el: '#payment_tenpay', model: App.payment_tenpay # 财付通
    self = this
    @collection.view = this
    _.bindAll this, 'render'
    @collection.bind 'add',(model) ->
      new App.Views.Payment.Show model: model
    @render()

    $('#shop_customer_accounts_required').click ->
      $('#customer-accounts-required').show()
    $('#shop_customer_accounts_optional,#shop_customer_accounts_').each ->
      $(this).click ->
        $('#customer-accounts-required').hide()

    $('#cancel_custom_payment_form').click ->
      $('#account_manual_payment_gateway').hide()
      $('#select_custom_payment_method option:eq(0)').attr 'selected', true
      false

  render: ->
    _(@collection.models).each (model) ->
      new App.Views.Payment.Show model: model

  select_method: ->
    name = this.$('#select_custom_payment_method').val()
    if name == ""
      this.$('#account_manual_payment_gateway').hide()
    else if name == "create_new"
      this.$('#account_manual_payment_gateway').show()
      this.$('#payment_name').focus()
      this.$('#payment_name').select()
    else
      this.$('#account_manual_payment_gateway').show()
      this.$('#payment_name').val name
      this.$('#payment_name').focus()

  change_checkout_config: ->
    action = $('form#checkout-config').attr('action')
    attrs = $('form#checkout-config').serialize()
    $.post action, attrs, ->
      msg 'Successfully modified!'

  save: ->
    $('form input#payment_submit').attr('disabled', true).val '正在保存...'
    self = this
    attrs =_.reduce this.$('form').serializeArray(), (result,obj) ->
      name = obj.name.replace(/payment\[|\]/g,"")
      result[name] = obj.value
      result
    ,{}
    @collection.create {
        name: attrs.name
        message: attrs.message
      },
      success: (model, resp) ->
        msg 'New success!'
        $('form input#payment_submit').attr('disabled', false).val 'Save'
        false
      error: (model,error)  ->
        error_msg error
        $('form input#payment_submit').attr('disabled', false).val 'Save'
