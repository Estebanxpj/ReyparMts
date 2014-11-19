# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# tax rates

tax_rate = TaxRate.create({:name => "maximo", :rate => 20.0})
exempt_tax = TaxRate.create({:name => "Sin Descuento", :rate => 0.0})
tax_rate1 = TaxRate.create({:name => "minimo", :rate => 10.0})
tax_rate2 = TaxRate.create({:name => "estandar", :rate => 15.0})

# delivery services

ds = DeliveryService.create({:name => "Next Day Delivery", :code => 'ND16', :courier => 'AnyCourier', :tracking_url => 'http://trackingurl.com/track/{{consignment_number}}'})
ds.delivery_service_prices.create({:code => 'Parcel', :min_weight => 0, :max_weight => 1, :price => 5.0, :cost_price => 4.50, :tax_rate => tax_rate})
ds.delivery_service_prices.create({:code => 'Parcel', :min_weight => 1, :max_weight => 5, :price => 8.0, :cost_price => 7.5, :tax_rate => tax_rate})
ds.delivery_service_prices.create({:code => 'Parcel', :min_weight => 5, :max_weight => 20, :price => 10.0, :cost_price => 9.50, :tax_rate => tax_rate})

ds = DeliveryService.create({:name => "Saturday Delivery", :code => 'NDSA16', :courier => 'AnyCourier', :tracking_url => 'http://trackingurl.com/track/{{consignment_number}}'})
ds.delivery_service_prices.create({:code => 'Parcel', :min_weight => 0, :max_weight => 1, :price => 27.0, :cost_price => 24.00, :tax_rate => tax_rate})
ds.delivery_service_prices.create({:code => 'Parcel', :min_weight => 1, :max_weight => 5, :price => 29.0, :cost_price => 20.00, :tax_rate => tax_rate})
ds.delivery_service_prices.create({:code => 'Parcel', :min_weight => 5, :max_weight => 20, :price => 37.0, :cost_price => 32.00,:tax_rate => tax_rate})

client1 = Client.create({:nit => '123456', :first_name => 'Pablo', :last_name => 'Neruda', :email_address => 'pabloneruda@hotmail.com', :company => 'Motosss', :billing_address1 => 'cr 96 # 49 AB 16', :billing_postcode => '57',:phone_number => '5869888'})
client1 = Client.create({:nit => '678901', :first_name => 'juan', :last_name => 'mora', :email_address => 'ablo@hotmail.com', :company => 'tor', :billing_address1 => 'cr 89 # 49 A 6', :billing_postcode => '57',:phone_number => '2345888'})
client1 = Client.create({:nit => '987654', :first_name => 'daniel', :last_name => 'lila', :email_address => 'oneru@hotmail.com', :company => 'Mosor', :billing_address1 => 'cr 46 # 6 B 96', :billing_postcode => '57',:phone_number => '58694567'})
# categories
cat1 = ProductCategory.create({:name => 'VoIP Phones'})
cat2 = ProductCategory.create({:name => 'VoIP Accessories'})
cat3 = ProductCategory.create({:name => 'Network Eqipment'})


def get_file(name, content_type = 'image/jpeg')
  file = ActionDispatch::Http::UploadedFile.new(:tempfile => File.open(File.join(shoope.root, 'db', 'seeds_data', name), 'rb'))
  file.original_filename = name
  file.content_type = content_type
  file
end

lorem = 'Todos los productos traen iva incluido'

pro = cat1.products.create({:name => 'GUAYA VEL AKT125 TT NAVCAR', :sku => 'A00001', :description => lorem, :short_description => 'todos los productos traen iva incluido', :weight => 1.119, :price => 4444.00, :cost_price => 4444.00, :tax_rate => tax_rate, :featured => true})
pro.default_image_file = get_file('t20p.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 100})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Yealink', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'T20P', :position => 1})
pro.product_attributes.create({:key => 'Colour', :value => 'Black', :position => 1})
pro.product_attributes.create({:key => 'Lines', :value => '3', :position => 1})
pro.product_attributes.create({:key => 'Colour Screen?', :value => 'No', :position => 1})
pro.product_attributes.create({:key => 'Power over ethernet?', :value => 'Yes', :position => 1})

pro = cat1.products.create({:name => 'AMORTIGUADOR AKT110S JGO', :sku => 'A00004', :description => lorem, :short_description => lorem, :weight => 1.419, :price => 64.99, :cost_price => 56.99, :tax_rate => tax_rate})
pro.default_image_file = get_file('t22p.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 200})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Yealink', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'T22P', :position => 1})
pro.product_attributes.create({:key => 'Colour', :value => 'Black', :position => 1})
pro.product_attributes.create({:key => 'Lines', :value => '4', :position => 1})
pro.product_attributes.create({:key => 'Colour Screen?', :value => 'No', :position => 1})
pro.product_attributes.create({:key => 'Power over ethernet?', :value => 'Yes', :position => 1})


pro = cat1.products.create({:name => 'HORQUILLA INF AKT 110 S ORG', :sku => 'A00006', :description => lorem, :short_description => lorem, :weight => 2.23, :price => 88.99, :cost_price => 78.99, :tax_rate => tax_rate})
pro.default_image_file = get_file('t26p.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 100})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Yealink', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'T26P', :position => 1})
pro.product_attributes.create({:key => 'Colour', :value => 'Black', :position => 1})
pro.product_attributes.create({:key => 'Lines', :value => '6', :position => 1})
pro.product_attributes.create({:key => 'Colour Screen?', :value => 'No', :position => 1})
pro.product_attributes.create({:key => 'Power over ethernet?', :value => 'Yes', :position => 1})

pro = cat1.products.create({:name => 'CUNA DIRECCION SUP AKT110S ORG', :sku => 'A00007', :description => lorem, :short_description => 'Colourful, sharp, fast & down right sexy. The Yealink T46P will make your scream!', :weight => 2.23, :price => 149.99, :cost_price => 139.99, :tax_rate => tax_rate, :featured => true})
pro.default_image_file = get_file('t46gn.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 100})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Yealink', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'T46GN', :position => 1})
pro.product_attributes.create({:key => 'Colour', :value => 'Black', :position => 1})
pro.product_attributes.create({:key => 'Lines', :value => '4', :position => 1})
pro.product_attributes.create({:key => 'Colour Screen?', :value => 'Yes', :position => 1})
pro.product_attributes.create({:key => 'Power over ethernet?', :value => 'Yes', :position => 1})

pro = cat1.products.create({:name => 'TUERCA DIRECCION AKT110S ORG', :sku => 'A00011', :description => lorem, :short_description => 'The perfect & beautiful VoIP phone for the discerning professional desk.', :featured => true})
pro.default_image_file = get_file('snom-870-grey.jpg')
pro.save!
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Snom', :position => 100})
pro.product_attributes.create({:key => 'Model', :value => '870', :position => 1})
pro.product_attributes.create({:key => 'Colour', :value => 'Grey', :position => 1})
pro.product_attributes.create({:key => 'Lines', :value => '10', :position => 1})
pro.product_attributes.create({:key => 'Colour Screen?', :value => 'Yes', :position => 1})
pro.product_attributes.create({:key => 'Power over ethernet?', :value => 'Yes', :position => 1})

v1 = pro.variants.create({:name => "White/Grey", :sku => "SM-870-GREY", :price => 230.00, :cost_price => 220, :tax_rate => tax_rate, :weight => 1.35, :default => true})
v1.default_image_file = get_file('snom-870-grey.jpg')
v1.save!
v1.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 4})


v2 = pro.variants.create({:name => "Black", :sku => "SM-870-BLK", :price => 230.00, :cost_price => 220, :tax_rate => tax_rate, :weight => 1.35})
v2.default_image_file = get_file('snom-870-blk.jpg')
v2.save!
v2.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 20})


pro = cat2.products.create({:name => 'Yealink Mono Headset', :sku => 'YL-YHS32', :description => lorem, :short_description => 'If you\'re often on the phone, this headset will make your life 100x easier. Guaranteed*.', :weight => 0.890, :price => 34.99, :cost_price => 24.99, :tax_rate => tax_rate, :featured => true})
pro.default_image_file = get_file('yhs32.jpg')
pro.save!
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Yealink', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'YHS32', :position => 1})

pro = cat2.products.create({:name => 'GUAYA VEL AKT110 S ', :sku => 'A00012 ', :description => lorem, :short_description => lorem, :weight => 0.780, :price => 38.00, :cost_price => 30, :tax_rate => tax_rate})
pro.default_image_file = get_file('snom-mm2.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 70})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Snom', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'MM2', :position => 1})

pro = cat2.products.create!({:name => 'GUARDAPOLVO SUSP BARRAS AKT110S ORG', :sku => 'A00013', :description => lorem, :short_description => lorem, :weight => 0.780, :price => 38.00, :cost_price => 30, :tax_rate => tax_rate})
pro.default_image_file = get_file('snom-mm2.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 50})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Snom', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'MM3', :position => 1})

pro = cat1.products.create({:name => 'ABRAZ SUP MANUBRIO AKT100S ORG', :sku => 'A00015', :description => lorem, :short_description => 'Wireless SIP phones are hard to come by but this beauty from Yealink is fab.', :weight => 1.280, :price => 99.99, :cost_price => 89.99, :tax_rate => tax_rate, :featured => true})
pro.default_image_file = get_file('w52p.jpg')
pro.save!
pro.stock_level_adjustments.create({:description => 'Initial Stock', :adjustment => 100})
pro.product_attributes.create({:key => 'Manufacturer', :value => 'Snom', :position => 1})
pro.product_attributes.create({:key => 'Model', :value => 'W52P', :position => 1})
pro.product_attributes.create({:key => 'Lines', :value => '3', :position => 1})
pro.product_attributes.create({:key => 'Colour Screen?', :value => 'Yes', :position => 1})
pro.product_attributes.create({:key => 'Power over ethernet?', :value => 'No', :position => 1})
# delivery services
