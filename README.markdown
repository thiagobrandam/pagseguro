# PAGSEGURO

Este é um plugin do Ruby on Rails que permite utilizar o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659), gateway de pagamentos do [UOL](http://uol.com.br).

## SOBRE O PAGSEGURO

### Carrinho Próprio

Trabalhando com carrinho próprio, sua loja mantém os dados do carrinho. O processo de inclusão de produtos no carrinho de compras acontece no próprio site da loja. Quando o comprador quiser finalizar sua compra, ele é enviado ao PagSeguro uma única vez com todos os dados de seu pedido. Aqui também, você tem duas opções. Pode enviar os dados do pedido e deixar o PagSeguro solicitar os dados do comprador, ou pode solicitar todos os dados necessários para a compra em sua loja e enviá-los ao PagSeguro.

### Retorno Automático

Após o processo de compra e pagamento, o usuário é enviado de volta a seu site. Para isso, você deve configurar uma [URL de retorno](https://pagseguro.uol.com.br/Security/ConfiguracoesWeb/RetornoAutomatico.aspx).

Antes de enviar o usuário para essa URL, o robô do PagSeguro faz um POST para ela, em segundo plano, com os dados e status da transação. Lendo esse POST, você pode obter o status do pedido. Se o pagamento entrou em análise, ou se o usuário pagou usando boleto bancário, o status será "Aguardando Pagamento" ou "Em Análise". Nesses casos, quando a transação for confirmada (o que pode acontecer alguns dias depois) a loja receberá outro POST, informando o novo status. **Cada vez que a transação muda de status, um POST é enviado.**

## REQUISITOS

A versão atual que está sendo mantida suporta Rails 3.0.0 ou superior.

Se você quiser esta biblioteca em versão mais antigas do Rails (2.3, por exemplo) deverá usar o [branch legacy](http://github.com/fnando/pagseguro/tree/legacy), QUE NÃO É MAIS MANTIDO.

## COMO USAR

### Configuração

O primeiro passo é instalar a biblioteca. Para isso, basta executar o comando

	gem install pagseguro

Adicione a biblioteca ao arquivo Gemfile:

~~~.ruby
gem "pagseguro", "~> 0.1.10"
~~~

Lembre-se de utilizar a versão que você acabou de instalar.

Depois de instalar a biblioteca, você precisará executar gerar o arquivo de configuração, que deve residir em `config/pagseguro.yml`. Para gerar um arquivo de modelo execute

	rails generate pagseguro:install

O arquivo de configuração gerado será parecido com isto:

~~~.yml
development: &development
  developer: true
  base: "http://localhost:3000"
  return_to: "/pedido/efetuado"
  authenticity_token: 9CA8D46AF0C6177CB4C23D76CAF5E4B0
  email: user@example.com

test:
  <<: *development

production:
  authenticity_token: 9CA8D46AF0C6177CB4C23D76CAF5E4B0
  email: user@example.com
  return_to: "/pedido/efetuado"
~~~

Esta gem possui um modo de desenvolvimento que permite simular a realização de pedidos e envio de notificações; basta utilizar a opção `developer`. Ela é ativada por padrão nos ambientes de desenvolvimento e teste. Você deve configurar as opções `base`, que deverá apontar para o seu servidor e a URL de retorno, que deverá ser configurada no próprio [PagSeguro](https://pagseguro.uol.com.br/?ind=689659), na página <https://pagseguro.uol.com.br/Security/ConfiguracoesWeb/RetornoAutomatico.aspx>.

Para o ambiente de produção, que irá efetivamente enviar os dados para o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659), você precisará adicionar o e-mail cadastrado como vendedor e o `authenticity_token`, que é o Token para Conferência de Segurança, que pode ser conseguido na página <https://pagseguro.uol.com.br/Security/ConfiguracoesWeb/RetornoAutomatico.aspx>.

### Montando o formulário

Para montar o seu formulário, você deverá utilizar a classe `PagSeguro::Order`. Esta classe deverá ser instanciada recebendo uma referência, que deve ser única do pedido. Esta referência permitirá identificar o pedido quando o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659) notificar seu site sobre uma alteração no status do pedido.

~~~.ruby
class CartController < ApplicationController
  def checkout
    # Busca o pedido associado ao usuario; esta logica deve
    # ser implementada por voce, da maneira que achar melhor
    @invoice = current_user.invoices.last

    # Instanciando o objeto para geracao do formulario
    @order = PagSeguro::Order.new(@invoice.id)

    # adicionando os produtos do pedido ao objeto do formulario
    @invoice.products.each do |product|
      # Estes sao os atributos necessarios. Por padrao,
      # quantidade (:quantity) eh definida como 1,
      # peso (:weight) eh definido para 0 e
      # frete (:shipping) eh definido como 0.
      @order.add :id => product.id, :amount => product.price, :description => product.title
    end
  end
end
~~~

Se você precisar, pode definir o tipo de frete com o método `shipping_type`.

~~~.ruby
@order.shipping_type = 1 # Encomenda normal (PAC)
@order.shipping_type = 2 # SEDEX
@order.shipping_type = 3 # Tipo de frete nao especificado
~~~

Se for utilizar o [redirecionamento para URL dinâmica](http://migre.me/5yfiG),
pode definir a url de retorno com o método `redirect_url` que deve receber a url
completa.

~~~.ruby
# Lembre-se que para rotas apelidadas, o complemento '_path' retorna
# a url relativa. Para ter a url completa, use o complemento '_url'.
@order.redirect_url = payment_confirmation_url
@order.redirect_url = 'http://example.com.br/confirmation'
~~~

Se você precisar, pode definir uma taxa extra ou desconto com o método `extra_amount`.

~~~.ruby
@order.extra_amount = 30.50 # Taxa extra
@order.extra_amount = -19.85 # Desconto
~~~

Se você precisar, pode definir o número máximo de vezes que o código de
pagamento criado pela chamada à API de Pagamentos poderá ser usado. Isso pode
ser feito com o método `max_uses` que deve receber um inteiro maior que 0.

~~~.ruby
@order.max_uses = 8
~~~

Se você precisar, pode definir o prazo (em segundos) durante o qual o código de
pagamento criado pela chamada à API de Pagamentos poderá ser usado. Isso pode
ser feito com o método `max_age` que deve receber um inteiro maior ou igual a 30.

~~~.ruby
@order.max_age = 60
~~~

Se você precisar, pode definir os dados de cobrança com o método `billing`.

~~~.ruby
@order.billing = {
  :name => 'John Doe',
  :email => 'john@doe.com',
  :phone_area_code => 22,
  :phone_numer => 12345678,
  :address_country => 'BRA',
  :address_state => 'AC',
  :address_city => 'Pantano Grande',
  :address_street => 'Rua Orobó',
  :address_postal_code => 28050035,
  :address_district => 'Tenório',
  :address_number => 72,
  :address_complement => 'Casa do fundo',
}
~~~

**Obs.:** Caso defina os dados de cobrança, a definição do tipo de frete
torna-se obrigatória e pode ser feita, como dito anteriormente, através do
método `shipping_type`.

Depois que você definiu os produtos do pedido, você pode exibir o formulário.

~~~.erb
<!-- app/views/cart/checkout.html.erb -->
<%= pagseguro_form @order, :submit => "Efetuar pagamento!" %>
~~~

Por padrão, o formulário montado usando email e token do arquivo de configuração. Você pode alterar esse padrão com as opções `:email` e `:token`.

~~~.erb
<%= pagseguro_form @order, :submit => "Efetuar pagamento!", :email => @account.email, :token => @account.token %>
~~~

### Recebendo notificações

Toda vez que o status de pagamento for alterado, o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659) irá notificar sua URL de retorno com diversos dados. Você pode interceptar estas notificações com o método `pagseguro_notification`. O bloco receberá um objeto da classe `PagSeguro::Notification` e só será executado se for uma notificação verificada junto ao [PagSeguro](https://pagseguro.uol.com.br/?ind=689659).

~~~.ruby
class CartController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def confirm
    return unless request.post?

	pagseguro_notification do |notification|
	  # Aqui voce deve verificar se o pedido possui os mesmos produtos
	  # que voce cadastrou. O produto soh deve ser liberado caso o status
	  # do pedido seja "completed" ou "approved"
	end

	render :nothing => true
  end
end
~~~
O método `pagseguro_notification` também pode receber como parâmetro o `authenticity_token` que será usado pra verificar a autenticação.

~~~.ruby
class CartController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def confirm
    return unless request.post?
	# Se voce receber pagamentos de contas diferentes, pode passar o
	# authenticity_token adequado como parametro para pagseguro_notification
	account = Account.find(params[:seller_id])
	pagseguro_notification(account.authenticity_token) do |notification|
	end

	render :nothing => true
  end
end
~~~

O objeto `notification` possui os seguintes métodos:

* `PagSeguro::Notification#products`: Lista de produtos enviados na notificação.
* `PagSeguro::Notification#shipping`: Valor do frete
* `PagSeguro::Notification#status`: Status do pedido
* `PagSeguro::Notification#payment_method`: Tipo de pagamento
* `PagSeguro::Notification#processed_at`: Data e hora da transação
* `PagSeguro::Notification#buyer`: Dados do comprador
* `PagSeguro::Notification#valid?(force=false)`: Verifica se a notificação é válida, confirmando-a junto ao PagSeguro. A resposta é jogada em cache e pode ser forçada com `PagSeguro::Notification#valid?(:force)`

**ATENÇÃO:** Não se esqueça de adicionar `skip_before_filter :verify_authenticity_token` ao controller que receberá a notificação; caso contrário, uma exceção será lançada.

### Utilizando modo de desenvolvimento

Toda vez que você enviar o formulário no modo de desenvolvimento, um arquivo YAML será criado em `tmp/pagseguro-#{Rails.env}.yml`. Esse arquivo conterá todos os pedidos enviados.

Depois, você será redirecionado para a URL de retorno que você configurou no arquivo `config/pagseguro.yml`. Para simular o envio de notificações, você deve utilizar a rake `pagseguro:notify`.

	$ rake pagseguro:notify ID=<id do pedido>

O ID do pedido deve ser o mesmo que foi informado quando você instanciou a class `PagSeguro::Order`. Por padrão, o status do pedido será `completed` e o tipo de pagamento `credit_card`. Você pode especificar esses parâmetros como no exemplo abaixo.

	$ rake pagseguro:notify ID=1 PAYMENT_METHOD=invoice STATUS=canceled NOTE="Enviar por motoboy" NAME="José da Silva" EMAIL="jose@dasilva.com"

#### PAYMENT_METHOD

* `credit_card`: Cartão de crédito
* `invoice`: Boleto
* `online_transfer`: Pagamento online
* `pagseguro`: Transferência entre contas do PagSeguro

#### STATUS

* `completed`: Completo
* `pending`: Aguardando pagamento
* `approved`: Aprovado
* `verifying`: Em análise
* `canceled`: Cancelado
* `refunded`: Devolvido

### Codificação (Encoding)

Esta biblioteca assume que você está usando UTF-8 como codificação de seu projeto. Neste caso, o único ponto onde os dados são convertidos para UTF-8 é quando uma notificação é enviada do UOL em ISO-8859-1.

Se você usa sua aplicação como ISO-8859-1, esta biblioteca NÃO IRÁ FUNCIONAR. Nenhum patch dando suporte ao ISO-8859-1 será aplicado; você sempre pode manter o seu próprio fork, caso precise.

## TROUBLESHOOTING

**Quero utilizar o servidor em Python para testar o retorno automático, mas recebo OpenSSL::SSL::SSLError (SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B)**

Neste caso, você precisa forçar a validação do POST enviado. Basta acrescentar a linha:

~~~.ruby
pagseguro_notification do |notification|
  notification.valid?(:force => true)
  # resto do codigo...
end
~~~

## AUTOR:

Nando Vieira (<http://simplesideias.com.br>)

Recomendar no [Working With Rails](http://www.workingwithrails.com/person/7846-nando-vieira)

## COLABORADORES:

* Elomar (<http://github.com/elomar>)
* Rafael (<http://github.com/rafaels>)

## LICENÇA:

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

