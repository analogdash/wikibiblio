class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
		t.integer  "pageid"
		t.string   "title"
		t.string "categories"
		t.string "links"
      t.timestamps
    end
  end
end
