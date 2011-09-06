# encoding: utf-8
require 'spec_helper'

describe Hash do

  it 'should symbolize and underscorize keys recursively' do
    hash = {
      'type' => '1',
      'grossAmount' => '49900.00',
      'installmentCount' => '1',
      'paymentMethod' => { 'type' => '1', 'code' => '101' },
      'items' => {
        'item' => [
          { 'id' => '0001', 'quantity' => '1', 'amount' => '243.00' },
          { 'id' => '0002', 'quantity' => '5', 'amount' => '256.35' }
        ]
      },
      'sender' => {
        'email' => 'comprador@uol.com.br',
        'phone' => { 'areaCode' => '11', 'number' => '56273440' }
      },
      'shipping' => {
        'address' => { 'postalCode' => '01452002', 'country' => 'BRA' }
      }
    }
    result_hash = hash.recursive_symbolize_underscorize_keys!
    result_hash.should == hash
    hash.should == {
      :type => '1',
      :gross_amount => '49900.00',
      :installment_count => '1',
      :payment_method => { :type => '1', :code => '101' },
      :items => {
        :item => [
          { :id => '0001', :quantity => '1', :amount => '243.00' },
          { :id => '0002', :quantity => '5', :amount => '256.35' }
        ]
      },
      :sender => {
        :email => 'comprador@uol.com.br',
        :phone => { :area_code => '11', :number => '56273440' }
      },
      :shipping => {
        :address => { :postal_code => '01452002', :country => 'BRA' }
      }
    }
  end
end

