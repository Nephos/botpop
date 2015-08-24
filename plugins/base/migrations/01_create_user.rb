Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String    :name, null: false, unique: true
      TrueClass :admin
      String    :groups
    end
  end
end
