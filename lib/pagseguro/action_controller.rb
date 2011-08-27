module PagSeguro
  module ActionController
    private
    def pagseguro_notification(token = nil, &block)
      return unless request.post?

      notification = PagSeguro::Notification.new(params, token)
      yield notification if notification.valid?
    end

    def pagseguro_payment_path(code)
      PagSeguro.gateway_url + "?code=#{code}"
    end

    def pagseguro_post(order, options={})
      header = { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' }

      # Add required params
      params = {
	      :email => options.fetch(:email, PagSeguro.config['email']),
	      :token => options.fetch(:token, PagSeguro.config['authenticity_token']),
	      :currency => 'BRL',
	      :reference => order.reference
      }

      # Add opitional params
	    params[:shippingType] = order.shipping_type if order.shipping_type
	    params[:redirectURL] = order.redirect_url if order.redirect_url
	    params[:extraAmount] = '%.2f' % order.extra_amount if order.extra_amount
	    params[:maxUses] = order.max_uses if order.max_uses
	    params[:maxAge] = order.max_age if order.max_age

	    # Add products
	    order.products.each_with_index do |product, i|
		    i += 1
		    params["itemId#{i}"] = product[:id]
		    params["itemDescription#{i}"] = product[:description]
		    params["itemAmount#{i}"] = '%.2f' % product[:amount]
		    params["itemQuantity#{i}"] = product[:quantity]
		    params["itemShippingCost#{i}"] = '%.2f' % product[:shipping] if product[:shipping]
		    params["itemWeight#{i}"] = product[:weight] if product[:shipping]
	    end

      # Add billing info
	    order.billing.each do |name, value|
		    params[PagSeguro::Order::BILLING_MAPPING[name.to_sym]] = value
	    end

      post_options = { :body => params, :headers => header }
	    response = HTTParty.post(PagSeguro.gateway_url, post_options)
	    hash = response.parsed_response.recursive_symbolize_keys
	    if hash[:checkout]
  	    hash[:checkout][:date] = hash[:checkout][:date].to_datetime
        return hash[:checkout]
      else
        return hash[:errors]
      end
    end
  end
end

