Rails.application.routes.draw do
  get "pagseguro_developer/confirm" => "pag_seguro/developer#confirm"
  get "pagseguro_developer/payment" => "pag_seguro/developer#payment"
  get "pagseguro_developer/notification" => "pag_seguro/developer#notification"
  post "pagseguro_developer" => "pag_seguro/developer#create"
end

