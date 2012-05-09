module PagSeguro
  module ActionController
    private
    def pagseguro_notification(options={}, &block)
      return unless request.post?
      query = { :email => options[:email] || PagSeguro.config['email'],
                :token => options[:token] || PagSeguro.config['authenticity_token'] }

      response = HTTParty.get(
                   pagseguro_notification_path(params['notificationCode']),
                   { :query => query }).
                 parsed_response.
                 recursive_symbolize_underscorize_keys!

      notification = PagSeguro::Notification.new(response[:transaction])
      yield notification
    end

    def pagseguro_notification_path(code)
      PagSeguro.gateway_notification_url + "/#{code}"
    end

    def pagseguro_payment_path(code)
      PagSeguro.gateway_payment_url + "?code=#{code}"
    end

    def pagseguro_post(order)
      header = { 'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8' }

      post_options = { :body => order.to_params, :headers => header }

      response = if PagSeguro.developer?
        PagSeguro::Faker.checkout_xml
      else
        HTTParty.post(PagSeguro.gateway_url, post_options).parsed_response
      end

      return :errors => [{:code => 'HTTP 401', :message => 'Unauthorized'}] if response == 'Unauthorized'

      response.recursive_symbolize_underscorize_keys!
      if response[:checkout]
        response[:checkout][:date] = response[:checkout][:date].to_datetime
        return response[:checkout]
      else
        errors = response[:errors][:error]
        response[:errors] = (errors.class == Hash) ? [errors] : errors
        return response
      end
    end
  end
end

