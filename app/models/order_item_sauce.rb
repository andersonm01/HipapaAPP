class OrderItemSauce < ApplicationRecord
  belongs_to :order_item
  belongs_to :sauce
end
