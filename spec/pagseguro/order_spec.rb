require "spec_helper"

describe PagSeguro::Order do
  before do
    @order = PagSeguro::Order.new
    @product = {:amount => 9.90, :description => "Ruby 1.9 PDF", :reference => 1}
  end

  it "should set order reference when instantiating object" do
    @order = PagSeguro::Order.new("ABCDEF")
    @order.reference.should == "ABCDEF"
  end

  it "should set order reference throught setter" do
    @order.reference = "ABCDEF"
    @order.reference.should == "ABCDEF"
  end

  it "should set order email throught setter" do
    @order.email = "john@doe.com"
    @order.email.should == "john@doe.com"
  end

  it "should set order token throught setter" do
    @order.token = "ABCDEF342432243AHI2"
    @order.token.should == "ABCDEF342432243AHI2"
  end

  it "should set order shipping type throught setter" do
    @order.shipping_type = 1
    @order.shipping_type.should == 1
  end

  it "should set order redirect url throught setter" do
    @order.redirect_url = 'http://example.com.br/confirmation'
    @order.redirect_url.should == 'http://example.com.br/confirmation'
  end

  it "should set order extra amount throught setter" do
    @order.extra_amount = -35.20
    @order.extra_amount.should == -35.20
  end

  it "should set order max uses throught setter" do
    @order.max_uses = 8
    @order.max_uses.should == 8
  end

  it "should set order max age throught setter" do
    @order.max_age = 60
    @order.max_age.should == 60
  end

  it "should reset products" do
    @order.products += [1,2,3]
    @order.products.should have(3).items
    @order.reset!
    @order.products.should be_empty
  end

  it "should alias add method" do
    @order.should_receive(:<<).with(:reference => 1)
    @order.add :reference => 1
  end

  it "should add product with default settings" do
    @order << @product
    @order.products.should have(1).item

    p = @order.products.first
    p[:amount].should == 9.90
    p[:description].should == "Ruby 1.9 PDF"
    p[:reference].should == 1
    p[:quantity].should == 1
    p[:weight].should be_nil
    p[:shipping].should be_nil
  end

  it "should add product with custom settings" do
    @order << @product.merge(:quantity => 3, :shipping => 3.50, :weight => 100)
    @order.products.should have(1).item

    p = @order.products.first
    p[:amount].should == 9.90
    p[:description].should == "Ruby 1.9 PDF"
    p[:reference].should == 1
    p[:quantity].should == 3
    p[:weight].should == 100
    p[:shipping].should == 3.50
  end

  it "should respond to billing attribute" do
    @order.should respond_to(:billing)
  end

  it "should initialize billing attribute" do
    @order.billing.should be_instance_of(Hash)
  end
end

