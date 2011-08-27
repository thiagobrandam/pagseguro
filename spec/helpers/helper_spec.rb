# -*- encoding: utf-8 -*-
require "spec_helper"

describe PagSeguro::Helper do
  before do
    PagSeguro.stub :developer?
  end

  context 'with default attributes' do
    subject { Nokogiri::HTML(helper.pagseguro_form('/payment')).css("form").first }

    it { should have_attr('action', '/payment') }
    it { should have_attr('class', 'pagseguro') }
    it { should have_input(:type => 'submit', :value => 'Pagar com PagSeguro') }
  end

  context 'with custom options' do
    subject {
      Nokogiri::HTML(helper.pagseguro_form('/pagseguro_payment',
                                           :submit => "Pague agora!",
                                           :params => { :reference => 158,
                                                        :name => 'John Doe' })).css("form").first
    }

    it { should have_input(:name => 'reference', :value => '158') }
    it { should have_input(:name => 'name', :value => 'John Doe') }
    it { should have_input(:type => 'submit', :value => 'Pague agora!') }
  end
end

