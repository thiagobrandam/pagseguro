# encoding: utf-8
module PagSeguro
  class Notification

    # Map order status from PagSeguro.
    #
    STATUS = {
      1 => :pending,
      2 => :verifying,
      3 => :paid,
      4 => :available,
      5 => :dispute,
      6 => :refunded,
      7 => :canceled
    }

    # Map the transaction type.
    #
    TRANSACTION_TYPE = {
      1 => :payment,
      2 => :transfer,
      3 => :adding_funds,
      4 => :charging,
      5 => :bonus
    }

    # Map payment method type from PagSeguro.
    #
    PAYMENT_METHOD = {
      1 => :credit_card,
      2 => :invoice,
      3 => :online_debit,
      4 => :pagseguro,
      5 => :oi_paggo
    }

    # Map payment method extra information from PagSeguro.
    #
    PAYMENT_METHOD_EXTRA_INFO = {
      101 => :visa,
      102 => :martercard,
      103 => :american_express,
      104 => :diners,
      105 => :hipercard,
      106 => :aura,
      107 => :elo,
      201 => :bradesco,
      202 => :santander,
      301 => :bradesco,
      302 => :itau,
      303 => :unibanco,
      304 => :banco_do_brasil,
      305 => :banco_real,
      306 => :banrisul,
      401 => :pagseguro,
      501 => :oi_paggo
    }

    # Map the shipping type.
    #
    SHIPPING_TYPE = {
      1 => :normal,
      2 => :sedex,
      3 => :unspecified
    }

    # The Rails params hash.
    #
    attr_accessor :params

    # Expects the params object from the current request.
    # PagSeguro will send POST with ISO-8859-1 encoded data,
    # so we need to normalize it to UTF-8.
    #
    def initialize(params)
      @params = PagSeguro.developer? ? params : normalize(params)
    end

    # Normalize the specified hash converting all data to UTF-8.
    #
    def normalize(hash)
      each_value(hash) do |value|
        Utils.to_utf8(value)
      end
    end

    # Denormalize the specified hash converting all data to ISO-8859-1.
    #
    def denormalize(hash)
      each_value(hash) do |value|
        Utils.to_iso8859(value)
      end
    end

    def status
      STATUS[params[:status].to_i]
    end

    def transaction_type
      TRANSACTION_TYPE[params[:type].to_i]
    end

    def payment_method
      PAYMENT_METHOD[params[:payment_method][:type].to_i]
    end

    def payment_method_extra_info
      PAYMENT_METHOD_EXTRA_INFO[params[:payment_method][:code].to_i]
    end

    def date
      params[:date].to_datetime
    end

    def buyer
      params[:sender]
    end

    # Return a list of products sent by PagSeguro.
    # The values will be normalized
    # (e.g. amount will be converted to cents, quantity will be an integer)
    #
    # Obs.: when products list has just one item, params[:items][:item] will
    # be a Hash. When products list has more then one item params[:items][:item]
    # will be an Array.
    #
    def products
      @products ||= begin
        items = params[:items][:item]
        if items.class == Hash
          items[:quantity] = items[:quantity].to_i
          items[:amount] = items[:amount].to_f
          [items]
        else
          items.each do |item|
            item[:quantity] = item[:quantity].to_i
            item[:amount] = item[:amount].to_f
          end
        end
      end
    end

    def shipping
      @shipping ||= begin
        shipping_type = params[:shipping][:type].to_i
        params[:shipping][:type] = SHIPPING_TYPE[shipping_type]
        params[:shipping][:cost] = params[:shipping][:cost].to_f if params[:shipping][:cost]
        params[:shipping]
      end
    end

    def method_missing(method, *args)
      # Attributes that return string
      string = [:reference, :code]
      return params[method] if string.include?(method)

      # Attributes that return float
      float = [:gross_amount, :discount_amount, :fee_amount, :net_amount, :extra_amount]
      return params[method].to_f if float.include?(method)

      # Attributes that return integer
      int = [:installment_count, :item_count]
      return params[method].to_i if int.include?(method)

      super
    end

    private
    def each_value(hash, &blk) # :nodoc:
      hash.each do |key, value|
        if value.kind_of?(Hash)
          hash[key] = each_value(value, &blk)
        else
          hash[key] = blk.call value
        end
      end

      hash
    end
  end
end

