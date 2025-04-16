ActiveAdmin.register Book do
  includes :utility
  includes :user

  permit_params = %i[
    genre author image title publisher year user_id utility_id
  ]

  member_action :copy, method: :get do
    @book = resource.dup
    render :new, layout: false
  end

  action_item :copy, only: :show do
    link_to(I18n.t('active_admin.clone_model', model: 'Book'),
            copy_admin_book_path(id: resource.id))
  end

  controller do
    define_method :permitted_params do
      params.permit(active_admin_namespace.permitted_params, book: permit_params)
    end
  end

  index do
    selectable_column
    column :id
    column :genre
    column :author
    column :image
    column :title
    column :publisher
    column :year
    actions
  end

  show do |book|
    render 'show', locals: { book: book }
    active_admin_comments
  end

  form do |f|
    f.inputs 'Book Details', allow_destroy: true do
      f.semantic_errors(*f.object.errors.keys)
      f.input :utility_id, as: :select, collection: Utility.all.collect { |u| [u.name, u.id] }
      f.input :user_id, as: :select, collection: User.all.collect { |u| [u.email, u.id] }
      f.input :genre
      f.input :author
      f.input :image
      f.input :title
      f.input :publisher
      f.input :year
      f.actions
    end
  end
end
