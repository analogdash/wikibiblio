class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string "title"
      t.string "articles"
      t.timestamps
    end
  end
end
