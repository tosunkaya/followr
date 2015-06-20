ActiveAdmin.register User do
  controller do
    def find_resource
      User.find_by_id(params[:id])
    end
  end


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  
  filter :twitter_username
  filter :created_at

  index do 
    selectable_column
    id_column

    column :name
    column :twitter_username
    column :created_at
    column :twitter_check?
    column (:hashtags) { |u| u.hashtags.join(',') }
    actions
  end

end
