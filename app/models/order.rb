class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items
  has_many :products, through: :order_items, dependent: :destroy

  enum state: %i[created]

    before_create -> { generate_number(hash_prefix, hash_size)}
    before_save :update_total

  def add_product(product_id, quantity)
      product = Product.find(product_id)

        if product && (product.stock > 0) && (product.stock >= quantity.to_i)
              self.order_items.create(product: product, quantity: quantity, price: product.price)
              self.total = self.total.to_f + (product.price *  quantity.to_i)
        end
  end  

  def generate_number(prefix, size)
   	self.number ||= loop do
     	  random = random_candidate(prefix, size)
      	break random unless self.class.exists?(number: random)
    	end
 	end

  def random_candidate(prefix, size)
    "#{prefix}#{Array.new(size){ rand(size) }.join }"
  end

  def hash_prefix
    'BO'
  end

  def hash_size
    9
  end	

  def update_total
    self.total = self.order_items.map{ |item| item.price * item.quantity }.sum
  end    

end



