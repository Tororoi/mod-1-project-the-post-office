class CreateReceivers < ActiveRecord::Migration[5.0]
  def change
    create_table :receivers do |t|
      t.string :name
      t.string :address
    end
  end
end
