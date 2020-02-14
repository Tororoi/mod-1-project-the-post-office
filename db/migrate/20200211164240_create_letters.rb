class CreateLetters < ActiveRecord::Migration[5.0]
  def change
    create_table :letters do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :content
      t.boolean :exists
    end
  end
end
