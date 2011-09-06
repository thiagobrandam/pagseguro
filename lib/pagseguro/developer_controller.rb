# -*- encoding : utf-8 -*-

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

    def notification
      # TODO: To this right
      xml = '<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<transaction>
    <date>2011-02-10T16:13:41.000-03:00</date>
    <code>9E884542-81B3-4419-9A75-BCC6FB495EF1</code>
    <reference>REF1234</reference>
    <type>1</type>
    <status>3</status>
    <paymentMethod>
        <type>1</type>
        <code>101</code>
    </paymentMethod>
    <grossAmount>49900.00</grossAmount>
    <discountAmount>0.00</discountAmount>
    <feeAmount>0.00</feeAmount>
    <netAmount>49900.00</netAmount>
    <extraAmount>0.00</extraAmount>
    <installmentCount>1</installmentCount>
    <itemCount>2</itemCount>
    <items>
        <item>
            <id>0001</id>
            <description>Notebook Prata</description>
            <quantity>1</quantity>
            <amount>24300.00</amount>
        </item>
        <item>
            <id>0002</id>
            <description>Notebook Rosa</description>
            <quantity>1</quantity>
            <amount>25600.00</amount>
        </item>
    </items>
    <sender>
        <name>José Comprador</name>
        <email>comprador@uol.com.br</email>
        <phone>
            <areaCode>11</areaCode>
            <number>56273440</number>
        </phone>
    </sender>
    <shipping>
        <address>
            <street>Av. Brig. Faria Lima</street>
            <number>1384</number>
            <complement>5o andar</complement>
            <district>Jardim Paulistano</district>
            <postalCode>01452002</postalCode>
            <city>Sao Paulo</city>
            <state>SP</state>
            <country>BRA</country>
        </address>
        <type>1</type>
        <cost>21.50</cost>
    </shipping>
</transaction>'
      render :xml => xml
    end
  end
end

