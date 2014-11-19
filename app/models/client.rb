class Client < ActiveRecord::Base

	self.table_name = 'client'
  scope :nit, -> nits { where(nit: nits) }
  scope :ordered, -> { order(:id)}
    # Validations
 belongs_to :ordered_clients, :polymorphic => true
 belongs_to :order, :class_name => 'Order', :touch => true

    def description
      "#{nit} (#{company})"
    end


def self.search(search)
 

    where('nit LIKE ?', "%#{search}%")

end
end
