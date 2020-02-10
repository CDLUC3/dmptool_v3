class CreateIdentifiers < ActiveRecord::Migration
  def change
    create_table :identifiers do |t|
      t.string     :value, null: false
      t.text       :attrs
      t.references :identifier_scheme, null: true
      t.references :identifiable, polymorphic: true
      t.timestamps
    end

    add_index :identifiers, [:identifiable_type, :identifiable_id]
    add_index :identifiers, [:identifier_scheme, :value]
    add_index :identifiers, [:identifiable_type, :identifiable_id, :identifiable_type]
  end
end
