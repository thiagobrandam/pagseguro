# -*- encoding : utf-8 -*-
module PagSeguro
  extend self

  # PagSeguro receives all invoices in this URL. If developer mode is enabled,
  # then the URL will be /pagseguro_developer/invoice
  GATEWAY_URL = "https://ws.pagseguro.uol.com.br/v2/checkout"
  GATEWAY_PAYMENT_URL = "https://pagseguro.uol.com.br/v2/checkout/payment.html"
  GATEWAY_NOTIFICATION_URL = "https://ws.pagseguro.uol.com.br/v2/transactions/notifications"


  # Map order status from PagSeguro.
  #
  STATUS = {
    :pending => 'Aguardando pagamento',
    :verifying => 'Em análise',
    :paid => 'Paga',
    :available => 'Disponível',
    :dispute => 'Em disputa',
    :refunded => 'Devolvida',
    :canceled => 'Cancelada'
  }

  # Map the transaction type.
  #
  TRANSACTION_TYPE = {
    :payment => 'Pagamento',
    :transfer => 'Transferência',
    :adding_funds => 'Adição de fundos',
    :charging => 'Cobrança',
    :bonus => 'Bônus'
  }

  # Map payment method type from PagSeguro.
  #
  PAYMENT_METHOD = {
    :credit_card => 'Cartão de crédito',
    :invoice => 'Boleto',
    :online_debit => 'Débito online',
    :pagseguro => 'Saldo PagSeguro',
    :oi_paggo => 'Oi Paggo'
  }

  # Map payment method extra information from PagSeguro.
  #
  PAYMENT_METHOD_EXTRA_INFO = {
    :visa => 'Visa',
    :martercard => 'MasterCard',
    :american_express => 'American Express',
    :diners => 'Diners',
    :hipercard => 'Hipercard',
    :aura => 'Aura',
    :elo => 'Elo',
    :bradesco => 'Bradesco',
    :santander => 'Santander',
    :bradesco => 'Bradesco',
    :itau => 'Itaú',
    :unibanco => 'Unibanco',
    :banco_do_brasil => 'Banco do Brasil',
    :banco_real => 'Banco Real',
    :banrisul => 'Banrisul',
    :pagseguro => 'Saldo PagSeguro',
    :oi_paggo => 'Oi Paggo'
  }

  # Map the shipping type.
  #
  SHIPPING_TYPE = {
    :normal => 'Encomenda normal',
    :sedex => 'SEDEX',
    :unspecified => 'Não especificado'
  }

  # Hold the config/pagseguro.yml contents
  @@config = nil

  # The path to the configuration file
  def config_file
    Rails.root.join("config/pagseguro.yml")
  end

  # Check if configuration file exists.
  def config?
    File.exist?(config_file)
  end

  # Load configuration file.
  def config
    raise MissingConfigurationError, "file not found on #{config_file.inspect}" unless config?

    # load file if is not loaded yet
    @@config ||= YAML.load_file(config_file)

    # raise an exception if the environment hasn't been set
    # or if file is empty
    if @@config == false || !@@config[Rails.env]
      raise MissingEnvironmentError, ":#{Rails.env} environment not set on #{config_file.inspect}"
    end

    # retrieve the environment settings
    @@config[Rails.env]
  end

  # The gateway URL will point to a local URL is
  # app is running in developer mode
  def gateway_url
    if developer?
      PagSeguro.config['base'] + '/pagseguro_developer'
    else
      GATEWAY_URL
    end
  end

  # The gateway URL will point to a local URL is
  # app is running in developer mode
  def gateway_payment_url
    if developer?
      PagSeguro.config['base'] + '/pagseguro_developer/payment'
    else
      GATEWAY_PAYMENT_URL
    end
  end

  # The gateway URL will point to a local URL is
  # app is running in developer mode
  def gateway_notification_url
    if developer?
      PagSeguro.config['base'] + '/pagseguro_developer/notification'
    else
      GATEWAY_NOTIFICATION_URL
    end
  end

  # Reader for the `developer` configuration
  def developer?
    config? && config["developer"] == true
  end

  class MissingEnvironmentError < StandardError; end
  class MissingConfigurationError < StandardError; end
end

