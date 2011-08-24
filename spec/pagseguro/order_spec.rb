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

