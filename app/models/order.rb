  class Order < ActiveRecord::Base

    self.table_name = 'orders'
  
    # Orders can have properties   
    # Require dependencies
    require_dependency 'order/states'
    require_dependency 'order/actions'
    require_dependency 'order/billing'
    require_dependency 'order/delivery'
    
    # All items which make up this order
    has_many :order_items, :dependent => :destroy, :class_name => 'OrderItem'
    accepts_nested_attributes_for :order_items, :allow_destroy => true, :reject_if => Proc.new { |a| a['ordered_item_id'].blank? }

    belongs_to :delivery_service, :class_name => 'DeliveryService'

    belongs_to :delivery_country, :class_name => 'Country', :foreign_key => 'delivery_country_id'
    belongs_to :clients, :class_name => 'Client'

    define_model_callbacks :ship
  
    STATUSES = ['building', 'confirming', 'received', 'accepted', 'rejected', 'shipped']
    # All products which are part of this order (accessed through the items)
    
    has_many :products, :through => :order_items, :class_name => 'Product', :source => :ordered_item, :source_type => 'Product'
    
    scope :ordered, -> { order(:id => :desc)}
     scope :received, -> {where("received_at is not null")}
      scope :pending, -> { where(:status => 'received') }

    # If an order has been received and something changes the delivery service or the delivery price
    # is cleared, we will re-cache all the delivery pricing so that we have the latest.
    # Validations
    #validates :client_id, :presence => true
   # validates :token, :presence => true
    #with_options :if => Proc.new { |o| !o.building? } do |order|
     # order.validates :email_address, :format => {:with => /\A\b[A-Z0-9\.\_\%\-\+]+@(?:[A-Z0-9\-]+\.)+[A-Z]{2,6}\b\z/i}
      #order.validates :phone_number, :format => {:with => /\A[\d\ \-x\(\)]{7,}\z/}
   # end
  
    validate do
      if self.delivery_required?
        if self.delivery_service.nil?
          errors.add :delivery_service_id, "must be specified"
        elsif !self.valid_delivery_service?
          errors.add :delivery_service_id, "is not suitable for this order"
        end
      end
    end
    
    
    # Cache delivery prices for the order
    def cache_delivery_pricing
      if self.delivery_service
        write_attribute :delivery_service_id, self.delivery_service.id
        write_attribute :delivery_price, self.delivery_price
        write_attribute :delivery_cost_price, self.delivery_cost_price
        write_attribute :delivery_tax_rate, self.delivery_tax_rate
      else
        write_attribute :delivery_service_id, nil
        write_attribute :delivery_price, nil
        write_attribute :delivery_cost_price, nil
        write_attribute :delivery_tax_rate, nil
        write_attribute :delivery_tax_amount, nil
      end
    end
    
    # Cache prices and save the order
    def cache_delivery_pricing!
      cache_delivery_pricing
      save!
    end
    
    # Has this order been shipped?
    #
    # @return [Boolean]
    def shipped?
      !!self.shipped_at?
    end
    
    # The total weight of the order
    #
    # @return [BigDecimal]
    def total_weight
      order_items.inject(BigDecimal(0)) { |t,i| t + i.total_weight}
    end
    
    # Is delivery required for this order?
    #
    # @return [Boolean]
    def delivery_required?
      total_weight > BigDecimal(0)
    end
    
    # An array of all the delivery services which are suitable for this order in it's
    # current state (based on its current weight)
    #
    # @return [Array] an array of Shoppe::DeliveryService objects
    def available_delivery_services
      delivery_service_prices.map(&:delivery_service).uniq
    end
    
    # An array of all the delivery service prices which can be applied to this order.
    #
    # @return [Array] an array of Shoppe:DeliveryServicePrice objects
    def delivery_service_prices
      if delivery_required?
        prices = DeliveryServicePrice.joins(:delivery_service).where(:shoppe_delivery_services => {:active => true}).order(:price).for_weight(total_weight)
        prices = prices.select { |p| p.countries.empty? || p.country?(self.delivery_country) }
        prices = prices.group_by { |dsp| dsp.delivery_service.default? }
        (prices[true] || []) | (prices[false] || [])
      else
        []
      end
    end

    # The recommended delivery service for this order
    #
    # @return [Shoppe::DeliveryService]
    def delivery_service
      super || available_delivery_services.first
    end
  
    # Return the delivery price for this order in its current state
    #
    # @return [BigDecimal]
    def delivery_service_price
      self.delivery_service && self.delivery_service.delivery_service_prices.for_weight(self.total_weight).first
    end
  
    # The price for delivering this order in its current state
    #
    # @return [BigDecimal]
    def delivery_price
      read_attribute(:delivery_price) || delivery_service_price.try(:price) || BigDecimal(0)
    end
  
    # The cost of delivering this order in its current state
    #
    # @return [BigDecimal]
    def delivery_cost_price
      read_attribute(:delivery_cost_price) || delivery_service_price.try(:cost_price) || BigDecimal(0)
    end
  
    # The tax amount due for the delivery of this order in its current state
    #
    # @return [BigDecimal]
    def delivery_tax_amount
      read_attribute(:delivery_tax_amount) ||
      delivery_price / BigDecimal(100) * delivery_tax_rate
    end
  
    # The tax rate for the delivery of this order in its current state
    #
    # @return [BigDecimal]
    def delivery_tax_rate
      read_attribute(:delivery_tax_rate) ||
      delivery_service_price.try(:tax_rate).try(:rate_for, self) ||
      BigDecimal(0)
    end
  
    # Is the currently assigned delivery service appropriate for this order?
    #
    # @return [Boolean]
    def valid_delivery_service?
      self.delivery_service ? self.available_delivery_services.include?(self.delivery_service) : !self.delivery_required?
    end
  
    # Remove the associated delivery service if it's invalid
    def remove_delivery_service_if_invalid
      unless self.valid_delivery_service?
        self.delivery_service = nil
        self.save
      end
    end
  
    # The URL which can be used to track the delivery of this order
    #
    # @return [String]
    def courier_tracking_url
      return nil if self.shipped_at.blank? || self.consignment_number.blank?
      @courier_tracking_url ||= self.delivery_service.tracking_url_for(self)
    end
    
    # Mark this order as shipped
    def ship!(consignment_number, user = nil)
      run_callbacks :ship do
        self.shipped_at = Time.now
        self.shipper = user if user
        self.status = 'shipped'
        self.consignment_number = consignment_number
        self.save!
        OrderMailer.shipped(self).deliver
      end
    end
    # Set some defaults
    before_validation { self.token = SecureRandom.uuid  if self.token.blank? }
    
    # The order number
    #
    # @return [String] - the order number padded with at least 5 zeros
    def number
      id ? id.to_s.rjust(6, '0') : nil
    end
  
    # The length of time the customer spent building the order before submitting it to us.
    # The time from first item in basket to received.
    #
    # @return [Float] - the length of time
    def build_time
      return nil if self.received_at.blank?
      self.created_at - self.received_at
    end
  
    # The name of the customer in the format of "Company (First Last)" or if they don't have
    # company specified, just "First Last".
    #
    # @return [String]
    def customer_name
      company.blank? ? full_name : "#{company} (#{full_name})"
    end
    
    # The full name of the customer created by concatinting the first & last name
    #
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end
  
    # Is this order empty? (i.e. doesn't have any items associated with it)
    #
    # @return [Boolean]
    def empty?
      order_items.empty?
    end
  
    def available_delivery_services
      delivery_service_prices.map(&:delivery_service).uniq
    end


    def delivery_service_prices
      if delivery_required?
        prices = DeliveryServicePrice.joins(:delivery_service).where(:shoppe_delivery_services => {:active => true}).order(:price).for_weight(total_weight)
        prices = prices.select { |p| p.countries.empty? || p.country?(self.delivery_country) }
        prices = prices.group_by { |dsp| dsp.delivery_service.default? }
        (prices[true] || []) | (prices[false] || [])
      else
        []
      end
    end
    # Does this order have items?
    #
    # @return [Boolean]
    def has_items?
      total_items > 0
    end
  
    # Return the number of items in the order?
    #
    # @return [Integer]
    def total_items
      order_items.inject(0) { |t,i| t + i.quantity }
    end
    
    def self.ransackable_attributes(auth_object = nil) 
      ["id", "billing_postcode", "billing_address1", "billing_address2", "billing_address3", "billing_address4", "first_name", "last_name", "company", "email_address", "phone_number", "consignment_number", "status", "received_at"] + _ransackers.keys
    end
  
    def self.ransackable_associations(auth_object = nil)
      []
    end

       def billing_name
      company.blank? ? full_name : "#{full_name} (#{company})"
    end
    
    # The total cost of the order
    #
    # @return [BigDecimal]
    def total_cost
      self.delivery_cost_price + 
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total_cost }
    end
  
    # Return the price for the order
    #
    # @return [BigDecimal]
    def profit
      total_before_tax - total_cost
    end
    
    # The total price of all items in the basket excluding delivery
    #
    # @return [BigDecimal]
    def items_sub_total
      order_items.inject(BigDecimal(0)) { |t, i| t + i.sub_total }
    end
  
    # The total price of the order before tax
    #
    # @return [BigDecimal]
    def total_before_tax
      self.delivery_price + self.items_sub_total
    end
  
    # The total amount of tax due on this order
    #
    # @return [BigDecimal]
    def tax
      self.delivery_tax_amount +
      order_items.inject(BigDecimal(0)) { |t, i| t + i.tax_amount }
    end
  
    # The total of the order including tax
    #
    # @return [BigDecimal]
    def total
      self.delivery_price + 
      self.delivery_tax_amount + 
      order_items.inject(BigDecimal(0)) { |t, i| t + i.total }
    end
    
    # The total amount due on the order
    #
    # @return [BigDecimal]
    def balance
      @balance ||= total - amount_paid
    end
    
    # Is there a payment still outstanding on this order?
    #
    # @return [Boolean]
    def payment_outstanding?
      balance > BigDecimal(0)
    end
    
    # Has this order been paid in full?
    #
    # @return [Boolean]
    def paid_in_full?
      !payment_outstanding?
    end
  
    # Is the order invoiced?
    #
    # @return [Boolean]
    def invoiced?
      !invoice_number.blank?
    end
  

    def proceed_to_confirm(params = {})
      self.status = 'confirming'
      if self.update(params)
        true
      else
        false
      end
    end
  
    # This method should be executed by the application when the order should be completed
    # by the customer. It will raise exceptions if anything goes wrong or return true if
    # the order has been confirmed successfully
    #
    # @return [Boolean]
    def confirm!
      no_stock_of = self.order_items.select(&:validate_stock_levels)
      unless no_stock_of.empty?
        raise Errors::InsufficientStockToFulfil, :order => self, :out_of_stock_items => no_stock_of
      end
    
      run_callbacks :confirmation do
        # If we have successfully charged the card (i.e. no exception) we can go ahead and mark this
        # order as 'received' which means it can be accepted by staff.
        self.status = 'received'
        self.received_at = Time.now
        self.save!

        self.order_items.each(&:confirm!)

        # Send an email to the customer
        OrderMailer.received(self).deliver
      end
    
      # We're all good.
      true
    end
  
    # Mark order as accepted
    #
    # @param user [Shoppe::User] the user who carried out this action    
    def accept!(user = nil)
      transaction do
        run_callbacks :acceptance do
          self.accepted_at = Time.now
          self.accepter = user if user
          self.status = 'accepted'
          self.save!
          self.order_items.each(&:accept!)
          Shoppe::OrderMailer.accepted(self).deliver
        end
      end
    end
  
    # Mark order as rejected
    #
    # @param user [Shoppe::User] the user who carried out the action
    def reject!(user = nil)
      transaction do
        run_callbacks :rejection do
          self.rejected_at = Time.now
          self.rejecter = user if user
          self.status = 'rejected'
          self.save!
          self.order_items.each(&:reject!)
          Shoppe::OrderMailer.rejected(self).deliver
        end
      end
    end

  end