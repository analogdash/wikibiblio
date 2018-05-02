class Addwikitex < ActiveRecord::Migration[5.1]
  def change
    add_column :revisions, :wikitext, :string
  end
end
