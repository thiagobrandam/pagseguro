module PagSeguro::Helper
  def pagseguro_custom_form(path, options={})
    options.reverse_merge!(:submit => 'Pagar com PagSeguro', :params => {})
    render :partial => "/pagseguro_custom_form",
           :locals => {:path => path, :options => options}
  end

  # Opções para imagem:
  #  :text - :comprar, :pagar, :carrinho (default: :pagar)
  #  :size - '84x35', '94x45', '160x120', '180x25', '205x30' (default: '205x30')
  #  :color - :verde, :azul, :preto, :cinza, :laranja, :roxo (default: :verde)
  def pagseguro_default_form(order, options={})
    image_base_url = 'https://p.simg.uol.com.br/out/pagseguro/i/botoes/pagamentos/'
    image_extention = '.gif'
    image_default_options = '205x30-pagar'

    image = options[:image]
    if image and image.class == Hash
      image_options = []
      image_options << image[:size] ? image[:size] : '205x30'
      image_options << image[:text] ? image[:text].to_s : 'pagar'
      if image[:color] and image[:color] != :verde
        image_options << image[:color].to_s
      end
      options[:image] = image_base_url + image_options.join('-') + image_extention
    elsif image.nil? or image.class != String
      options[:image] = image_base_url + image_default_options + image_extention
    end
    render :partial => "/pagseguro_default_form", :locals => {:options => options, :order => order}
  end
end

