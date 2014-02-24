# encoding: utf-8
ActiveAdmin.register Theme do

  index do
    column :id
    column :name
    column :style
    column :color
    column :price
    default_actions
  end

  form html: { :enctype => "multipart/form-data" } do |f|
    f.inputs "Basic Information" do
      f.input :published
      f.input :position
      f.input :name
      f.input :handle      , hint: 'Name'
      f.input :style
      f.input :style_handle, hint: 'The English name of the style，Theme is only one style, enter the default'
      f.input :role        , as: :radio          , collection: KeyValues::Theme::Role.options
      f.input :price
      f.input :color       , as: :radio          , collection: Theme::COLOR
      f.input :desc        , as: :text           , input_html: { rows: 10 }
    end
    f.inputs "Author Information" do
      f.input :shop
      f.input :site  , as: :url
      f.input :author
      f.input :email , as: :email
    end
    f.inputs "Related Documents" do
      f.input :file, as: :file, hint: 'Please upload tar.bz2 file，Be careful not to have a top-level directory，Unzip the package directly put layouts,assets,config,snippets,templates Directory'
      f.input :main, as: :file, hint: 'main(500x642)'
      f.input :collection, as: :file, hint: 'collection(850x600)'
      f.input :product, as: :file, hint: 'product(850x600)'
    end
    f.buttons
  end

end
