Rails.application.routes.draw do
  get "pagseguro_developer/confirm", :to => "pag_seguro/developer#confirm"
  get "pagseguro_payment", :to => "pag_seguro/developer#payment"
  post "pagseguro_developer", :to => "pag_seguro/developer#create"
end

