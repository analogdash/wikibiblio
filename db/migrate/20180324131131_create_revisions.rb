class CreateRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :revisions do |t|
		t.integer  "revid"
		t.integer  "pageid"
		t.integer  "parentid"
		t.string   "user"
		t.integer  "userid"
		t.integer  "size"
		t.datetime "timestamp"
		t.string   "comment"
		t.string "content"
		t.timestamps
    end
  end
end
