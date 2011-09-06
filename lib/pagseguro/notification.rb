# encoding: utf-8
module PagSeguro
  class Notification

    # Map order status from PagSeguro.
    #
    STATUS = {
      1 => { :sym => :pending, :name => 'Aguardando pagamento' },
      2 => { :sym => :verifying, :name => 'Em análise' },
      3 => { :sym => :paid, :name => 'Paga' },
      4 => { :sym => :available, :name => 'Disponível' },
      5 => { :sym => :dispute, :name => 'Em disputa' },
      6 => { :sym => :refunded, :name => 'Devolvida' },
      7 => { :sym => :canceled, :name => 'Cancelada' }
    }

    # Map the transaction type.
    #
    TRANSACTION_TYPE = {
      1 => { :sym => :payment, :name => 'Pagamento' },
      2 => { :sym => :transfer, :name => 'Transferência' },
      3 => { :sym => :adding_funds, :name => 'Adição de fundos' },
      4 => { :sym => :charging, :name => 'Cobrança' },
      5 => { :sym => :bonus, :name => 'Bônus' }
    }

    # Map payment method type from PagSeguro.
    #
    PAYMENT_METHOD = {
      1 => { :sym => :credit_card, :name => 'Cartão de crédito' },
      2 => { :sym => :invoice, :name => 'Boleto' },
      3 => { :sym => :online_debit, :name => 'Débito online' },
      4 => { :sym => :pagseguro, :name => 'Saldo PagSeguro' },
      5 => { :sym => :oi_paggo, :name => 'Oi Paggo' }
    }

    # Map payment method extra information from PagSeguro.
    #
    PAYMENT_METHOD_EXTRA_INFO = {
      101 => { :sym => :visa, :name => 'Visa' },
      102 => { :sym => :martercard, :name => 'MasterCard' },
      103 => { :sym => :american_express, :name => 'American Express' },
      104 => { :sym => :diners, :name => 'Diners' },
      105 => { :sym => :hipercard, :name => 'Hipercard' },
      106 => { :sym => :aura, :name => 'Aura' },
      107 => { :sym => :elo, :name => 'Elo' },
      201 => { :sym => :bradesco, :name => 'Bradesco' },
      202 => { :sym => :santander, :name => 'Santander' },
      301 => { :sym => :bradesco, :name => 'Bradesco' },
      302 => { :sym => :itau, :name => 'Itaú' },
      303 => { :sym => :unibanco, :name => 'Unibanco' },
      304 => { :sym => :banco_do_brasil, :name => 'Banco do Brasil' },
      305 => { :sym => :banco_real, :name => 'Banco Real' },
      306 => { :sym => :banrisul, :name => 'Banrisul' },
      401 => { :sym => :pagseguro, :name => 'Saldo PagSeguro' },
      501 => { :sym => :oi_paggo, :name => 'Oi Paggo' }
    }

    # Map the shipping type.
    #
    SHIPPING_TYPE = {
      1 => { :sym => :normal, :name => 'Encomenda normal' },
      2 => { :sym => :sedex, :name => 'SEDEX' },
      3 => { :sym => :unspecified, :name => 'Não especificado' }
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
      STATUS[params[:status].to_i][:sym]
    end

    def status_name
      STATUS[params[:status].to_i][:name]
    end

    def transaction_type
      TRANSACTION_TYPE[params[:type].to_i][:sym]
    end

    def transaction_type_name
      TRANSACTION_TYPE[params[:type].to_i][:name]
    end

    def payment_method
      PAYMENT_METHOD[params[:payment_method][:type].to_i][:sym]
    end

    def payment_method_name
      PAYMENT_METHOD[params[:payment_method][:type].to_i][:name]
    end

    def payment_method_extra_info
      PAYMENT_METHOD_EXTRA_INFO[params[:payment_method][:code].to_i][:sym]
    end

    def payment_method_extra_info_name
      PAYMENT_METHOD_EXTRA_INFO[params[:payment_method][:code].to_i][:name]
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
    def products
      @products ||= begin
        params[:items][:item].each do |item|
          item[:quantity] = item[:quantity].to_i
          item[:amount] = item[:amount].to_f
        end
      end
    end

    def shipping
      @shipping ||= begin
        shipping_type = params[:shipping][:type].to_i
        params[:shipping][:type] = SHIPPING_TYPE[shipping_type][:sym]
        params[:shipping][:type_name] = SHIPPING_TYPE[shipping_type][:name]

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

