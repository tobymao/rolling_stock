Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :email, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :email, unique: true
    end

    create_enum :game_state, %w[new active finished]

    create_table :games do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      String :version, null: false
      column :users, 'integer[]', null: false
      column :deck, 'integer[]', null: false
      String :settings, null: false
      game_state :state, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :user_id
      index :users, type: 'gin'
    end

    create_table :actions do
      primary_key :id
      foreign_key :game_id, :games, null: false, on_delete: :cascade
      Integer :round, null: false
      Integer :phase, null: false
      String :data, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :game_id
    end

  end
end
