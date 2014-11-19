class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string   :nit
      t.string   :first_name
      t.string   :last_name
      t.string   :company
      t.string   :billing_address1
      t.string   :billing_postcode
      t.integer  :billing_country_id
      t.integer  :tax_rate_id
      t.string   :email_address
      t.string   :phone_number  
      t.datetime :created_at
      t.datetime :updated_at
      t.timestamps
    end
  end
end
