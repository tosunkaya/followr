ActiveAdmin.register User do
  controller do
    def find_resource
      User.find_by_id(params[:id])
    end
  end
  
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
