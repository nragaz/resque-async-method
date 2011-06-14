class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.date :born_on
      t.datetime :locked_at

      t.timestamps
    end
  end
end
