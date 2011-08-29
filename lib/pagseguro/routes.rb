Rails.application.routes.draw do
  get "pagseguro_developer/confirm" => "pag_seguro/developer#confirm"
  post "pagseguro_developer" => "pag_seguro/developer#create"
  get "pagseguro_developer_payment" => "pag_seguro/developer#payment"
end

