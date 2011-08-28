# -*- encoding: utf-8 -*-
require "spec_helper"

describe PagSeguro::Helper do
  before do
    PagSeguro.stub :developer?
  end

  context 'PagSeguro default form' do
    before do
      @order = PagSeguro::Order.new("I1001")
    end

    subject {
      Nokogiri::HTML(helper.pagseguro_default_form(@order)).css("form").first
    }

    context "with custom attributes" do
      it 'receiver email' do
        page = Nokogiri::HTML(helper.pagseguro_default_form(@order, :email => "mary@example.com")).css("form").first

        page.should have_input(:name => "receiverEmail", :value => "mary@example.com")
      end

      it 'customized pagseguro image' do
        page = Nokogiri::HTML(helper.pagseguro_default_form(@order, :image => {:size => "94x45",
                                                                    :color => :azul,
                                                                    :text => :comprar})).css("form").first
        page.should have_input(:name => "submit",
                               :type => "image",
                               :src => "https://p.simg.uol.com.br/out/pagseguro/i/botoes/pagamentos/94x45-comprar-azul.gif")
      end

      it 'custom image' do
        page = Nokogiri::HTML(helper.pagseguro_default_form(@order, :image => "http://example.com/image.png")).css("form").first

        page.should have_input(:name => "submit",
                               :type => "image",
                               :src => "http://example.com/image.png")
      end
    end

    context "with default attributes" do
      it { should have_attr("action", PagSeguro::GATEWAY_PAYMENT_URL) }
      it { should have_attr("class", "pagseguro") }
      it { should have_input(:name => "charset", :value => "UTF-8") }
      it { should have_input(:name => "receiverEmail", :value => "john@doe.com") }
      it { should have_input(:name => "currency", :value => "BRL") }
      it { should have_input(:name => "reference", :value => "I1001") }
      it { should have_input(:name => "submit",
                             :type => "image",
                             :alt => "Pagar com PagSeguro",
                             :src => "https://p.simg.uol.com.br/out/pagseguro/i/botoes/pagamentos/205x30-pagar.gif") }
    end

    it "should include shipping type" do
      @order.shipping_type = 1
      subject.should have_input(:name => "shippingType", :value => "1")
    end

    it "should include extra amount" do
      @order.extra_amount = -35.20
      subject.should have_input(:name => "extraAmount", :value => "-35.20")
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

  context 'PagSeguro custom form' do
    context 'with default attributes' do
      subject { Nokogiri::HTML(helper.pagseguro_custom_form('/payment')).css("form").first }

      it { should have_attr('action', '/payment') }
      it { should have_attr('class', 'pagseguro') }
      it { should have_input(:type => 'submit', :value => 'Pagar com PagSeguro') }
    end

    context 'with custom options' do
      subject {
        Nokogiri::HTML(helper.pagseguro_custom_form('/pagseguro_payment',
                                                    :submit => "Pague agora!",
                                                    :params => { :reference => 158,
                                                                 :name => 'John Doe' }
                                                    )).css("form").first
      }

      it { should have_input(:name => 'reference', :value => '158') }
      it { should have_input(:name => 'name', :value => 'John Doe') }
      it { should have_input(:type => 'submit', :value => 'Pague agora!') }
    end
  end
end

