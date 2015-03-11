Rails.application.routes.draw do
  get 'diagnostics' => 'diagnostics#index'
  post 'hello' => 'messages#receive'
end
