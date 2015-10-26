Rails.application.routes.draw do
  get 'skidmarks' => 'skidmarks#index'
  get 'skidmarks-plot' => 'skidmarks#plot'
end