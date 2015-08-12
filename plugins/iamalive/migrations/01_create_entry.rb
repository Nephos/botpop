Sequel.migration do
  change do
    create_table(:entries) do
      primary_key :id
      String :user, null: false
      String :message, null: false, text: true
      DateTime :created_at
    end
  end
end
