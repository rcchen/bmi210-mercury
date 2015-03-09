Rails.application.routes.draw do
  post 'hello' => 'messages#receive'
end
