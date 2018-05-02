class CreateReferenceInstances < ActiveRecord::Migration[5.1]
  def change
    create_table :reference_instances do |t|
        t.string "revid"
        t.string "reftype"
        t.string "wikitext"
        t.integer "size"
        t.integer "position"
        t.string "refname"
        t.string "content"
        t.string "comments"
        t.string "factoid"
        t.timestamps
    end
  end
end
