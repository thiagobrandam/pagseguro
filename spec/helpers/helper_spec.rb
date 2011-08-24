# -*- encoding: utf-8 -*-
require "spec_helper"

describe PagSeguro::Helper do
  before do
    @order = PagSeguro::Order.new("I1001")
    PagSeguro.stub :developer?
  end

  subject {
    Nokogiri::HTML(helper.pagseguro_form(@order)).css("form").first
  }

  context "with default attributes" do
    it { should have_attr("action", PagSeguro::GATEWAY_URL) }
    it { should have_attr("class", "pagseguro") }
    it { should have_input(:name => "charset", :value => "UTF-8") }
    it { should have_input(:name => "email", :value => "john@doe.com") }
    it { should have_input(:name => "token", :value => "9CA8D46AF0C6177CB4C23D76CAF5E4B0") }
    it { should have_input(:name => "currency", :value => "BRL") }
    it { should have_input(:name => "reference", :value => "I1001") }
    it { should have_input(:type => "submit", :value => "Pagar com PagSeguro") }
  end

  it "should include shipping type" do
    @order.shipping_type = 1
    subject.should have_input(:name => "shippingType", :value => "1")
  end

  it "should include redirect url" do
    @order.redirect_url = "http://example.com.br/confirmation"
    subject.should have_input(:name => "redirectURL", :value => "http://example.com.br/confirmation")
  end

  it "should include extra amount" do
    @order.extra_amount = -35.20
    subject.should have_input(:name => "extraAmount", :value => "-35.20")
  end

  it "should include max uses" do
    @order.max_uses = 8
    subject.should have_input(:name => "maxUses", :value => "8")
  end

  it "should include max age" do
    @order.max_age = 60
    subject.should have_input(:name => "maxAge", :value => "60")
  end

  context "with custom attributes" do
    subject {
      Nokogiri::HTML(helper.pagseguro_form(@order, :submit => "Pague agora!",
                                           :email => "mary@example.com",
                                           :token => "5BD8D46AC1C6177AA5C23D76CAF6A5F2")).css("form").first
    }

    it { should have_input(:name => "email", :value => "mary@example.com") }
    it { should have_input(:name => "token", :value => "5BD8D46AC1C6177AA5C23D76CAF6A5F2") }
    it { should have_input(:type => "submit", :value => "Pague agora!") }
  end

  context "with minimum product info" do
    before do
      @order << { :id => 1001, :amount => 10.00, :description => "Rails 3 e-Book" }
    end

    it { should have_input(:name => "itemId1", :value => "1001") }
    it { should have_input(:name => "itemDescription1", :value => "Rails 3 e-Book") }
    it { should have_input(:name => "itemQuantity1", :value => "1") }
    it { should have_input(:name => "itemAmount1", :value => "10.00") }
    it { should_not have_input(:name => "itemShippingCost1") }
    it { should_not have_input(:name => "itemWeight1") }
  end

  context "with optional product info" do
    before do
      @order << { :id => 1001, :amount => 10.00, :description => "T-Shirt", :weight => 300, :shipping => 8.50, :quantity => 2 }
    end

    it { should have_input(:name => "itemQuantity1", :value => "2") }
    it { should have_input(:name => "itemShippingCost1", :value => "8.50") }
    it { should have_input(:name => "itemWeight1", :value => "300") }
  end

  context "with multiple products" do
    before do
      @order << { :id => 1001, :amount => 10.00, :description => "Rails 3 e-Book" }
      @order << { :id => 1002, :amount => 19.30, :description => "Rails 3 e-Book + Screencast" }
    end

    it { should have_input(:name => "itemId1", :value => "1001") }
    it { should have_input(:name => "itemDescription1", :value => "Rails 3 e-Book") }
    it { should have_input(:name => "itemQuantity1", :value => "1") }
    it { should have_input(:name => "itemAmount1", :value => "10.00") }

    it { should have_input(:name => "itemId2", :value => "1002") }
    it { should have_input(:name => "itemDescription2", :value => "Rails 3 e-Book + Screencast") }
    it { should have_input(:name => "itemQuantity2", :value => "1") }
    it { should have_input(:name => "itemAmount2", :value => "19.30") }
  end

  context "with billing info" do
    before do
      @order.billing = {
	      :name => 'John Doe',
	      :email => 'john@doe.com',
	      :phone_area_code => 22,
	      :phone_number => 12345678,
	      :address_country => 'BRA',
	      :address_state => 'AC',
	      :address_city => 'Pantano Grande',
	      :address_street => 'Rua Orobó',
	      :address_postal_code => 28050035,
	      :address_district => 'Tenório',
	      :address_number => 72,
	      :address_complement => 'Casa do fundo',
      }
    end

    it { should have_input(:name => "senderName", :value => "John Doe") }
    it { should have_input(:name => "senderEmail", :value => "john@doe.com") }
    it { should have_input(:name => "senderAreaCode", :value => "22") }
    it { should have_input(:name => "senderPhone", :value => "12345678") }
    it { should have_input(:name => "shippingAddressCountry", :value => "BRA") }
    it { should have_input(:name => "shippingAddressState", :value => "AC") }
    it { should have_input(:name => "shippingAddressCity", :value => "Pantano Grande") }
    it { should have_input(:name => "shippingAddressPostalCode", :value => "28050035") }
    it { should have_input(:name => "shippingAddressDistrict", :value => "Tenório") }
    it { should have_input(:name => "shippingAddressStreet", :value => "Rua Orobó") }
    it { should have_input(:name => "shippingAddressNumber", :value => "72") }
    it { should have_input(:name => "shippingAddressComplement", :value => "Casa do fundo") }
  end
end

