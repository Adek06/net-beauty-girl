class CreateGirlPhotoPosts < ActiveRecord::Migration[6.0]
  def change
    create_table :girl_photo_posts do |t|
      t.string :url
      t.string :imgs, array: true
      t.string :content
      t.boolean :isPush

      t.timestamps
    end
  end
end
