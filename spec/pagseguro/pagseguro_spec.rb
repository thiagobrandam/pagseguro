# -*- encoding : utf-8 -*-
require "spec_helper"

describe PagSeguro do
  describe "configuration" do
    before do
      @config_file = Rails.root.join("config/pagseguro.yml")
      @contents = YAML.load_file(@config_file)
      File.stub :exists? => true
      YAML.stub :load_file => @contents

      module PagSeguro; @@config = nil; end
    end

    it "should raise error if configuration is not found" do
      File.should_receive(:exist?).with(@config_file).and_return(false)
      expect { PagSeguro.config }.to raise_error(PagSeguro::MissingConfigurationError)
    end

    it "should raise error if no environment is set on config file" do
      YAML.should_receive(:load_file).with(@config_file).and_return({})
      expect { PagSeguro.config }.to raise_error(PagSeguro::MissingEnvironmentError)
    end

    it "should raise error if config file is empty" do
      # YAML.load_file return false when file is zero-byte
      YAML.should_receive(:load_file).with(@config_file).and_return(false)
      expect { PagSeguro.config }.to raise_error(PagSeguro::MissingEnvironmentError)
    end

    context 'urls' do
      context 'gateway' do
        it "should return local url if developer mode is enabled" do
          PagSeguro.should_receive(:developer?).and_return(true)
          PagSeguro.gateway_url.should == "http://localhost:3000/pagseguro_developer"
        end

        it "should return real url if developer mode is disabled" do
          PagSeguro.should_receive(:developer?).and_return(false)
          PagSeguro.gateway_url.should == "https://ws.pagseguro.uol.com.br/v2/checkout"
        end
      end

      context 'gateway payment' do
        it "should return local url if developer mode is enabled" do
          PagSeguro.should_receive(:developer?).and_return(true)
          PagSeguro.gateway_payment_url.should == "http://localhost:3000/pagseguro_developer_payment"
        end

        it "should return real url if developer mode is disabled" do
          PagSeguro.should_receive(:developer?).and_return(false)
          PagSeguro.gateway_payment_url.should == "https://pagseguro.uol.com.br/v2/checkout/payment.html"
        end
      end

      context 'gateway notification' do
        it "should return local url if developer mode is enabled" do
          PagSeguro.should_receive(:developer?).and_return(true)
          PagSeguro.gateway_notification_url.should == "http://localhost:3000/pagseguro_developer_notification"
        end

        it "should return real url if developer mode is disabled" do
          PagSeguro.should_receive(:developer?).and_return(false)
          PagSeguro.gateway_notification_url.should == "https://ws.pagseguro.uol.com.br/v2/transactions/notifications"
        end
      end
    end

    it "should read configuration developer mode" do
      PagSeguro.stub :config => {"developer" => true}
      PagSeguro.should be_developer

      PagSeguro.stub :config => {"developer" => false}
      PagSeguro.should_not be_developer
    end
  end

  describe 'constants' do
    it 'status mapping' do
      PagSeguro::STATUS[:pending].should == 'Aguardando pagamento'
      PagSeguro::STATUS[:verifying].should == 'Em análise'
      PagSeguro::STATUS[:paid].should == 'Paga'
      PagSeguro::STATUS[:available].should == 'Disponível'
      PagSeguro::STATUS[:dispute].should == 'Em disputa'
      PagSeguro::STATUS[:refunded].should == 'Devolvida'
      PagSeguro::STATUS[:canceled].should == 'Cancelada'
    end

    it 'transaction type mapping' do
      PagSeguro::TRANSACTION_TYPE[:payment].should == 'Pagamento'
      PagSeguro::TRANSACTION_TYPE[:transfer].should == 'Transferência'
      PagSeguro::TRANSACTION_TYPE[:adding_funds].should == 'Adição de fundos'
      PagSeguro::TRANSACTION_TYPE[:charging].should == 'Cobrança'
      PagSeguro::TRANSACTION_TYPE[:bonus].should == 'Bônus'
    end

    it 'payment method mapping' do
      PagSeguro::PAYMENT_METHOD[:credit_card].should == 'Cartão de crédito'
      PagSeguro::PAYMENT_METHOD[:invoice].should == 'Boleto'
      PagSeguro::PAYMENT_METHOD[:online_debit].should == 'Débito online'
      PagSeguro::PAYMENT_METHOD[:pagseguro].should == 'Saldo PagSeguro'
      PagSeguro::PAYMENT_METHOD[:oi_paggo].should == 'Oi Paggo'
    end

    it 'payment method extra information mapping' do
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:visa].should == 'Visa'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:martercard].should == 'MasterCard'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:american_express].should == 'American Express'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:diners].should == 'Diners'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:hipercard].should == 'Hipercard'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:aura].should == 'Aura'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:elo].should == 'Elo'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:bradesco].should == 'Bradesco'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:santander].should == 'Santander'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:bradesco].should == 'Bradesco'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:itau].should == 'Itaú'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:unibanco].should == 'Unibanco'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:banco_do_brasil].should == 'Banco do Brasil'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:banco_real].should == 'Banco Real'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:banrisul].should == 'Banrisul'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:pagseguro].should == 'Saldo PagSeguro'
      PagSeguro::PAYMENT_METHOD_EXTRA_INFO[:oi_paggo].should == 'Oi Paggo'
    end

    it 'shipping type mapping' do
      PagSeguro::SHIPPING_TYPE[:normal].should == 'Encomenda normal'
      PagSeguro::SHIPPING_TYPE[:sedex].should == 'SEDEX'
      PagSeguro::SHIPPING_TYPE[:unspecified].should == 'Não especificado'
    end
  end
end

