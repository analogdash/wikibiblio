class Addflagrefscrape < ActiveRecord::Migration[5.1]
  def change
    add_column :revisions, :scraped, :boolean
  end
end
