class CreateCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :calls do |t|
      t.string :sid

      t.string :from
      t.string :to
      t.string :message_record_url
      t.integer :duration, default: 0
      t.integer :message_duration, default: 0
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :calls, :sid, unique: true
  end
end
