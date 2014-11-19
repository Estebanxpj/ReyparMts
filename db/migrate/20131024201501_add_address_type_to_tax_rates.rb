class AddAddressTypeToTaxRates < ActiveRecord::Migration
  def change
    add_column :tax_rates, :address_type, :string
  end
end