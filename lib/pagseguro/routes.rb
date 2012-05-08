Rails.application.routes.draw do
  get "pagseguro_developer_confirm" => "pag_seguro/developer#confirm"
  get "pagseguro_developer_payment" => "pag_seguro/developer#payment"
  get "pagseguro_developer_notification" => "pag_seguro/developer#notification"
  post "pagseguro_developer" => "pag_seguro/developer#create"
end

