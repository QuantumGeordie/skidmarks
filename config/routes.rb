Rails.application.routes.draw do
  match 'skidmarks' => 'skidmarks#index'
  match 'skidmarks-plot' => 'skidmarks#plot'
end