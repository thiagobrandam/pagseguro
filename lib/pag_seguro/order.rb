module PagSeguro
  class Order
    # Map all billing attributes that will be added as form inputs.
    BILLING_MAPPING = {
      :name => 'senderName',
      :email => 'senderEmail',
      :phone_area_code => 'senderAreaCode',
      :phone_number => 'senderPhone',
      :address_country => 'shippingAddressCountry',
      :address_state => 'shippingAddressState',
      :address_city => 'shippingAddressCity',
      :address_street => 'shippingAddressStreet',
      :address_postal_code => 'shippingAddressPostalCode',
      :address_district => 'shippingAddressDistrict',
      :address_number => 'shippingAddressNumber',
      :address_complement => 'shippingAddressComplement',
    }

    # The list of products added to the order
    attr_accessor :products

    # The billing info that will be sent to PagSeguro.
    attr_accessor :billing

    # Define the shipping type.
    # The allowed values are:
    # - 1 (Normal order (PAC))
    # - 2 (SEDEX)
    # - 3 (Unspecified type of Shipping)
    attr_accessor :shipping_type

    # Define the redirect url for dynamic redirect.
    # Reference: http://migre.me/5yfiG
    attr_accessor :redirect_url

    # Define the token. The default is the one on config/pagseguro.yml
    attr_accessor :token

    # Define the email. The default is the one on config/pagseguro.yml
    attr_accessor :email

    # Define the extra amount that should be added or subtracted from the total.
    # Should be a decimal (positive or negative), with two decimal places.
    attr_accessor :extra_amount

    # Define the maximum number of times that the code created by the payment of
    # Payments API call can be used.
    # Should be a integer > 0.
    attr_accessor :max_uses

    # Define the time (in seconds) which the payment code created by the
    # Payment API call can be used.
    # Should be a integer >= 30.
    attr_accessor :max_age

    def initialize(order_reference = nil)
      reset!
      self.reference = order_reference
      self.billing = {}
    end

    # Set the order reference. Should be a unique
    # value to identify this order on your own application
    def reference=(ref)
      @reference = ref
    end

    # Get the order reference
    def reference
      @reference
    end

    # Remove all products from this order
    def reset!
      @products = []
    end

    # Add a new product to the PagSeguro order
    # The allowed values are:
    # - id (Required. Text. Should match the product on your database)
    # - description (Required. Text. Identifies the product)
    # - quantity (Required. Integer >= 1 and <= 999. Defaults to 1)
    # - amount (Required. Decimal, with two decimal places separated by a dot)
    # - weight (Optional. Integer corresponding to the weight in grammes)
    # - shipping (Optional. Decimal, with two decimal places separated by a dot)
    def <<(options)
      options = {
        :weight => nil,
        :shipping => nil,
        :quantity => 1
      }.merge(options)

      options[:description] = "#{options[:description][0...97]}..." if options[:description] and options[:description].size > 100

      products.push(options)
    end

    def add(options)
      self << options
    end

    def to_params
      # Add required params
      params = {
        :email => self.email || PagSeguro.config['email'],
        :token => self.token || PagSeguro.config['authenticity_token'],
        :currency => 'BRL',
        :reference => self.reference
      }

      # Add opitional params
      params[:shippingType] = self.shipping_type if self.shipping_type
      params[:redirectURL] = self.redirect_url if self.redirect_url
      params[:extraAmount] = '%.2f' % self.extra_amount if self.extra_amount
      params[:maxUses] = self.max_uses if self.max_uses
      params[:maxAge] = self.max_age if self.max_age

      # Add products
      self.products.each_with_index do |product, i|
        i += 1
        params["itemId#{i}"] = product[:id]
        params["itemDescription#{i}"] = product[:description]
        params["itemAmount#{i}"] = '%.2f' % product[:amount]
        params["itemQuantity#{i}"] = product[:quantity]
        params["itemShippingCost#{i}"] = '%.2f' % product[:shipping] if product[:shipping]
        params["itemWeight#{i}"] = product[:weight] if product[:weight]
      end

      # Add billing info
      self.billing.each do |name, value|
        params[PagSeguro::Order::BILLING_MAPPING[name.to_sym]] = value
      end

      params
    end
  end
end

