class Integritous < ActiveRecord::Migration[5.1]
  def change
    add_column :articles, :integritous, :boolean
  end
end
