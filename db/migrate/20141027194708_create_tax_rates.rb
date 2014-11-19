class CreateTaxRates < ActiveRecord::Migration
  def change
    create_table :tax_rates do |t|
      t.string   :name
      t.decimal  :rate,        precision: 8, scale: 2
      t.datetime :created_at
      t.datetime :updated_at
      t.text     :country_ids
      t.timestamps
    end
  end
end
