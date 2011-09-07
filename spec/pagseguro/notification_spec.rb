# encoding: utf-8
require 'spec_helper'

describe PagSeguro::Notification do
  subject { PagSeguro::Notification.new(@the_params) }
  let(:payload) { YAML.load_file File.dirname(__FILE__) + '/../fixtures/notification.yml' }
  before { @the_params = {} }

  describe 'status mapping' do
    it 'should be pending' do
      param!(:status, '1')
      subject.status.should == :pending
    end

    it 'should be verifying' do
      param!(:status, '2')
      subject.status.should == :verifying
    end

    it 'should be paid' do
      param!(:status, '3')
      subject.status.should == :paid
    end

    it 'should be available' do
      param!(:status, '4')
      subject.status.should == :available
    end

    it 'should be dispute' do
      param!(:status, '5')
      subject.status.should == :dispute
    end

    it 'should be refunded' do
      param!(:status, '6')
      subject.status.should == :refunded
    end

    it 'should be canceled' do
      param!(:status, '7')
      subject.status.should == :canceled
    end
  end

  describe 'transaction type mapping' do
    it 'should be payment' do
      param!(:type, '1')
      subject.transaction_type.should == :payment
    end

    it 'should be transfer' do
      param!(:type, '2')
      subject.transaction_type.should == :transfer
    end

    it 'should be adding funds' do
      param!(:type, '3')
      subject.transaction_type.should == :adding_funds
    end

    it 'should be charging' do
      param!(:type, '4')
      subject.transaction_type.should == :charging
    end

    it 'should be bonus' do
      param!(:type, '5')
      subject.transaction_type.should == :bonus
    end
  end

  describe 'payment method mapping' do
    it 'should be credit card' do
      set_payment_method!('1')
      subject.payment_method.should == :credit_card
    end

    it 'should be invoice' do
      set_payment_method!('2')
      subject.payment_method.should == :invoice
    end

    it 'should be online debit' do
      set_payment_method!('3')
      subject.payment_method.should == :online_debit
    end

    it 'should be pagseguro' do
      set_payment_method!('4')
      subject.payment_method.should == :pagseguro
    end

    it 'should be oi paggo' do
      set_payment_method!('5')
      subject.payment_method.should == :oi_paggo
    end
  end

  describe 'payment method extra information mapping' do
    it 'should be visa' do
      set_payment_method_extra_info!('101')
      subject.payment_method_extra_info.should == :visa
    end

    it 'should be martercard' do
      set_payment_method_extra_info!('102')
      subject.payment_method_extra_info.should == :martercard
    end

    it 'should be american express' do
      set_payment_method_extra_info!('103')
      subject.payment_method_extra_info.should == :american_express
    end

    it 'should be diners' do
      set_payment_method_extra_info!('104')
      subject.payment_method_extra_info.should == :diners
    end

    it 'should be hipercard' do
      set_payment_method_extra_info!('105')
      subject.payment_method_extra_info.should == :hipercard
    end

    it 'should be aura' do
      set_payment_method_extra_info!('106')
      subject.payment_method_extra_info.should == :aura
    end

    it 'should be elo' do
      set_payment_method_extra_info!('107')
      subject.payment_method_extra_info.should == :elo
    end

    it 'should be bradesco' do
      set_payment_method_extra_info!('201')
      subject.payment_method_extra_info.should == :bradesco
    end

    it 'should be santander' do
      set_payment_method_extra_info!('202')
      subject.payment_method_extra_info.should == :santander
    end

    it 'should be bradesco' do
      set_payment_method_extra_info!('301')
      subject.payment_method_extra_info.should == :bradesco
    end

    it 'should be itau' do
      set_payment_method_extra_info!('302')
      subject.payment_method_extra_info.should == :itau
    end

    it 'should be unibanco' do
      set_payment_method_extra_info!('303')
      subject.payment_method_extra_info.should == :unibanco
    end

    it 'should be branco do brasil' do
      set_payment_method_extra_info!('304')
      subject.payment_method_extra_info.should == :banco_do_brasil
    end

    it 'should be branco real' do
      set_payment_method_extra_info!('305')
      subject.payment_method_extra_info.should == :banco_real
    end

    it 'should be banrisul' do
      set_payment_method_extra_info!('306')
      subject.payment_method_extra_info.should == :banrisul
    end

    it 'should be pagseguro' do
      set_payment_method_extra_info!('401')
      subject.payment_method_extra_info.should == :pagseguro
    end

    it 'should be oi paggo' do
      set_payment_method_extra_info!('501')
      subject.payment_method_extra_info.should == :oi_paggo
    end
  end

  describe 'other mappings' do
    it 'should map the order id' do
      param!(:reference, 'ABCDEF')
      subject.reference.should == 'ABCDEF'
    end

    it 'should map the processing date' do
      param!(:date, '2011-02-10T16:13:41.000-03:00')
      subject.date.should == '2011-02-10T16:13:41.000-03:00'.to_datetime
    end

    it 'should map the order id' do
      param!(:code, '9E884542-81B3-4419-9A75-BCC6FB495EF1')
      subject.code.should == '9E884542-81B3-4419-9A75-BCC6FB495EF1'
    end

    it 'should map the gross amount' do
      param!(:gross_amount, '25.45')
      subject.gross_amount.should == 25.45
    end

    it 'should map the discount amount' do
      param!(:discount_amount, '1.10')
      subject.discount_amount.should == 1.10
    end

    it 'should map the fee amount' do
      param!(:fee_amount, '5.20')
      subject.fee_amount.should == 5.20
    end

    it 'should map the net amount' do
      param!(:net_amount, '18.69')
      subject.net_amount.should == 18.69
    end

    it 'should map the extra amount' do
      param!(:extra_amount, '7.12')
      subject.extra_amount.should == 7.12
    end

    it 'should map the installment count' do
      param!(:installment_count, '12')
      subject.installment_count.should == 12
    end

    it 'should map the item count' do
      param!(:item_count, '5')
      subject.item_count.should == 5
    end
  end

  context 'products mapping' do
    it 'should map the products items' do
      set_product! :id => '13', :description => 'Ruby 1.9 PDF', :amount => '12.90', :quantity => '3'
      set_product! :id => '14', :description => 'Rails 3.1 PDF', :amount => '10.00', :quantity => '1'

      subject.products.should have(2).items

      p = subject.products.first
      p[:id].should == '13'
      p[:description].should == 'Ruby 1.9 PDF'
      p[:amount].should == 12.90
      p[:quantity].should == 3

      p = subject.products.last
      p[:id].should == '14'
      p[:description].should == 'Rails 3.1 PDF'
      p[:amount].should == 10.0
      p[:quantity].should == 1
    end
  end

  describe 'buyer mapping' do
    it 'should map the buyer info' do
      set_buyer! :email => 'john@doe.com', :name => 'John Doe',
                 :phone => { :area_code => '11', :number => '55551234' }

      subject.buyer[:email].should == 'john@doe.com'
      subject.buyer[:name].should == 'John Doe'
      subject.buyer[:phone][:area_code].should == '11'
      subject.buyer[:phone][:number].should == '55551234'
    end
  end

  describe 'shipping mapping' do
    context 'type' do
      it 'normal' do
        set_shipping! :type => '1'
        subject.shipping[:type] == :normal
      end

      it 'sedex' do
        set_shipping! :type => '2'
        subject.shipping[:type] == :sedex
      end

      it 'unspecified' do
        set_shipping! :type => '3'
        subject.shipping[:type] == :unspecified
      end
    end

    it 'should return cost' do
      set_shipping! :cost => '1.85'
      subject.shipping[:cost].should == 1.85
    end

    context 'address' do
      it 'should return country' do
        set_shipping! :address => { :country => 'BRA' }
        subject.shipping[:address][:country].should == 'BRA'
      end

      it 'should return state' do
        set_shipping! :address => { :state => 'SP' }
        subject.shipping[:address][:state].should == 'SP'
      end

      it 'should return city' do
        set_shipping! :address => { :city => 'São Paulo' }
        subject.shipping[:address][:city].should == 'São Paulo'
      end

      it 'should return postal code' do
        set_shipping! :address => { :postal_code => '01310300' }
        subject.shipping[:address][:postal_code].should == '01310300'
      end

      it 'should return district' do
        set_shipping! :address => { :district => 'Bela Vista' }
        subject.shipping[:address][:district].should == 'Bela Vista'
      end

      it 'should return street' do
        set_shipping! :address => { :street => 'Av. Paulista' }
        subject.shipping[:address][:street].should == 'Av. Paulista'
      end

      it 'should return number' do
        set_shipping! :address => { :number => '2500' }
        subject.shipping[:address][:number].should == '2500'
      end

      it 'should return complement' do
        set_shipping! :address => { :complement => 'Apto 123-A' }
        subject.shipping[:address][:complement].should == 'Apto 123-A'
      end
    end
  end

  private
  def set_payment_method!(value)
    subject.params[:payment_method] ||= {}
    subject.params[:payment_method].merge!(:type => value)
  end

  def set_payment_method_extra_info!(value)
    subject.params[:payment_method] ||= {}
    subject.params[:payment_method].merge!(:code => value)
  end

  def set_buyer!(options)
    subject.params[:sender] ||= {}
    subject.params[:sender].merge!(options)
  end

  def set_shipping!(options)
    options = { :type => '1' }.merge(options)
    subject.params[:shipping] ||= {}
    subject.params[:shipping].merge!(options)
  end

  def param!(name, value)
    subject.params.merge!(name => value)
  end

  def set_product!(options)
    subject.params[:items] ||= {}
    subject.params[:items][:item] ||= []

    subject.params[:items][:item] << {
      :id => options[:id],
      :description => options[:description],
      :amount => options[:amount],
      :quantity => options[:quantity]
    }
  end
end

