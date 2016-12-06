Sequel.migration do
  change do
    create_table :users do
      primary_key :id

      String :name, null: false
      String :password, null: false
      String :email, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :sessions do
      primary_key :id
      String :token, null: false, index: true, unique: true
      foreign_key :user_id, :users, null: false, index: true, on_delete: :cascade

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_enum :game_state, %w[new active finished]

    create_table :games do
      primary_key :id
      foreign_key :user_id, :users, null: false, index: true, on_delete: :cascade
      String :version, null: false
      column :users, 'integer[]', null: false
      column :deck, 'text[]', null: false
      String :settings, null: false
      game_state :state, null: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :users, type: 'gin'
    end

    create_table :actions do
      primary_key :id
      foreign_key :game_id, :games, null: false, index: true, on_delete: :cascade
      Integer :round, null: false
      Integer :phase, null: false
      String :turns, null: false, default: '[]'

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:game_id, :round, :phase], unique: true
    end
  end
end
