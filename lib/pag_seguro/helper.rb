module PagSeguro::Helper
  def pagseguro_form(path, options={})
    options.reverse_merge!(:submit => 'Pagar com PagSeguro', :params => {})
    render :partial => "pagseguro/pagseguro_form",
           :locals => {:path => path, :options => options}
  end
end

