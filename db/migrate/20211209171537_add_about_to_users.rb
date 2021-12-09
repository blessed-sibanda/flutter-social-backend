class AddAboutToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :about, :text, default: ""
  end
end
