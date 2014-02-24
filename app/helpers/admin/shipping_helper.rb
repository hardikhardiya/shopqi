#encoding: utf-8
module Admin::ShippingHelper
  def price_max_order_subtotal_helper(price_based_shipping_rate)
    if price_based_shipping_rate.max_order_subtotal.nil?
      "Least"
    else
      " - ¥#{price_based_shipping_rate.max_order_subtotal}"
    end
  end
end
