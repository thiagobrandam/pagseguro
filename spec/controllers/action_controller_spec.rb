# -*- encoding : utf-8 -*-

require "spec_helper"

describe PagSeguro::ActionController do
  include PagSeguro::ActionController

  before do
    @order = PagSeguro::Order.new('I1001')
    PagSeguro.stub(:gateway_url) {'http://localhost:3000'}
    @default_params = { :email => 'john@doe.com',
                        :token => '9CA8D46AF0C6177CB4C23D76CAF5E4B0',
                        :currency => 'BRL',
                        :reference => 'I1001'}
    @response = { 'checkout' => {'code' => '9CA8D46AF0C6177CB4C23D76CAF5E4B0',
                                 'date' => '2010-12-02T10:11:28.000-02:00' } }
  end

  def stub_post(params={})
    HTTParty.should_receive(:post).
      with(PagSeguro.gateway_url,
        hash_including(:body => @default_params.merge(params))).
          and_return(stub(:parsed_response => @response))
  end

  # TODO: This could be a route
  it "should return the payment url with given code" do
    code = '9CA8D46AF0C6177CB4C23D76CAF5E4B0'
    pagseguro_payment_path(code).should == PagSeguro.gateway_url + "/payment.html?code=#{code}"
  end

  context 'PagSeguro post with errors' do
    it 'should return a hash with errors code and message' do
      @response = { 'errors' => { 'error' => { 'code' => '11004', 'message' => 'Currency is required.' },
                                  'error' => { 'code' => '11005', 'message' => 'Currency invalid value: 100' } }}

      stub_post
      hash = { :error => { :code => '11004', :message => 'Currency is required.' },
               :error => { :code => '11005', :message => 'Currency invalid value: 100' } }
      pagseguro_post(@order).should == hash
    end
  end

  context 'PagSeguro post successfully' do
    it 'should return a hash with code and date' do
      hash = { :code => '9CA8D46AF0C6177CB4C23D76CAF5E4B0',
               :date => '2010-12-02T10:11:28.000-02:00'.to_datetime }
      stub_post
      pagseguro_post(@order).should == hash
    end

    context "should accept with custom option" do
      it 'email' do
        stub_post :email => 'mary@example.com'
        pagseguro_post(@order, :email => 'mary@example.com')
      end

      it 'token' do
        stub_post :token => '5BD8D46AC1C6177AA5C23D76CAF6A5F2'
        pagseguro_post(@order, :token => '5BD8D46AC1C6177AA5C23D76CAF6A5F2')
      end
    end

    context 'without without options' do
      after(:each) do
        pagseguro_post(@order)
      end

      it "should include shipping type" do
        @order.shipping_type = 1
        stub_post :shippingType => 1
      end

      it "should include redirect url" do
        @order.redirect_url = 'http://example.com.br/confirmation'
        stub_post :redirectURL => 'http://example.com.br/confirmation'
      end

      it "should include extra amount" do
        @order.extra_amount = -35.20
        stub_post :extraAmount => '-35.20'
      end

      it "should include max uses" do
        @order.max_uses = 8
        stub_post :maxUses => 8
      end

      it "should include max age" do
        @order.max_age = 60
        stub_post :maxAge => 60
      end

      context "with minimum product info" do
        before(:each) do
          @order << { :id => 1001, :amount => 10.00, :description => "Rails 3 e-Book" }
        end

        it 'should include the required info' do
          params = { 'itemId1' => 1001,
                     'itemDescription1' => 'Rails 3 e-Book',
                     'itemQuantity1' => 1,
                     'itemAmount1' => '10.00' }
          stub_post params
        end

        it 'should not include the optional info' do
          HTTParty.should_receive(:post).
            with(PagSeguro.gateway_url,
              hash_not_including('itemShippingCost1', 'itemWeight1')).
                and_return(stub(:parsed_response => @response))
        end
      end

      context "with optional product info" do
        it 'should include the optional info' do
          @order << { :id => 1001, :amount => 17.23, :description => 'T-Shirt',
                      :weight => 300, :shipping => 8.50, :quantity => 33 }

          params = { 'itemId1' => 1001,
                     'itemDescription1' => 'T-Shirt',
                     'itemQuantity1' => 33,
                     'itemAmount1' => '17.23',
                     'itemShippingCost1' => '8.50',
                     'itemWeight1' => 300}
          stub_post params
        end
      end

      context "with multiple products" do
        it 'should include all products' do
          @order << { :id => 1001, :amount => 18.07, :description => 'Rails 3 e-Book' }
          @order << { :id => 1002, :amount => 19.30, :description => 'E-Book + Screencast' }

          params = { 'itemId1' => 1001,
                     'itemDescription1' => 'Rails 3 e-Book',
                     'itemQuantity1' => 1,
                     'itemAmount1' => '18.07',
                     'itemId2' => 1002,
                     'itemDescription2' => 'E-Book + Screencast',
                     'itemQuantity2' => 1,
                     'itemAmount2' => '19.30' }
          stub_post params
        end
      end

      context "with billing info" do
        it 'should include all the billing info' do
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

          params = { 'senderName' => 'John Doe',
                     'senderEmail' => 'john@doe.com',
                     'senderAreaCode' => 22,
                     'senderPhone' => 12345678,
                     'shippingAddressCountry' => 'BRA',
                     'shippingAddressState' => 'AC',
                     'shippingAddressCity' => 'Pantano Grande',
                     'shippingAddressPostalCode' => 28050035,
                     'shippingAddressDistrict' => 'Tenório',
                     'shippingAddressStreet' => 'Rua Orobó',
                     'shippingAddressNumber' => 72,
                     'shippingAddressComplement' => 'Casa do fundo' }
          stub_post params
        end
      end
    end
  end
end

