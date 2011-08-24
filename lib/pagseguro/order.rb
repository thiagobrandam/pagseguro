module PagSeguro
  class Order
    # Map all billing attributes that will be added as form inputs.
    BILLING_MAPPING = {
      :sender_name => 'senderName',
      :sender_email => 'senderEmail',
      :sender_area_code => 'senderAreaCode',
      :sender_phone => 'senderPhone',
      :shipping_address_country => 'shippingAddressCountry',
      :shipping_address_state => 'shippingAddressState',
      :shipping_address_city => 'shippingAddressCity',
      :shipping_address_street => 'shippingAddressStreet',
      :shipping_address_postal_code => 'shippingAddressPostalCode',
      :shipping_address_district => 'shippingAddressDistrict',
      :shipping_address_number => 'shippingAddressNumber',
      :shipping_address_complement => 'shippingAddressComplement',
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

      products.push(options)
    end

    def add(options)
      self << options
    end
  end
end

