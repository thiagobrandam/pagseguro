module PagSeguro
  class DeveloperController < ::ActionController::Base
    skip_before_filter :verify_authenticity_token
    PAGSEGURO_ORDERS_FILE = File.join(Rails.root, "tmp", "pagseguro-#{Rails.env}.yml")

    def create
      require "digest/md5"

      payment_code = Digest::MD5.hexdigest(Time.now.to_s)
      payment_date = DateTime.now.to_s

      # create the orders file if doesn't exist
      FileUtils.touch(PAGSEGURO_ORDERS_FILE) unless File.exist?(PAGSEGURO_ORDERS_FILE)

      # YAML caveat: if file is empty false is returned;
      # we need to set default to an empty hash in this case
      orders = YAML.load_file(PAGSEGURO_ORDERS_FILE) || {}

      # add a new order, associating it with the order id
      orders[params[:reference]] = params.except(:controller, :action, :only_path, :authenticity_token)
      orders[params[:reference]][:code] = payment_code
      orders[params[:reference]][:date] = payment_date

      # save the file
      File.open(PAGSEGURO_ORDERS_FILE, "w+") do |file|
        file << orders.to_yaml
      end

      # create the xml response
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.checkout {
          xml.code payment_code
          xml.date payment_date
        }
      end
      render :xml => builder and return
    end

    def payment
      # redirect to the configuration url
      redirect_to PagSeguro.config["return_to"]
    end
  end
end

