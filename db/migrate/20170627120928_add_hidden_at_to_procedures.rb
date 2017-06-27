class AddHiddenAtToProcedures < ActiveRecord::Migration[5.0]
  def change
    add_column :procedures, :hidden_at, :datetime
    add_index :procedures, :hidden_at
  end
end
