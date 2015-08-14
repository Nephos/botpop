Sequel.migration do
  change do
    create_table(:admins) do
      primary_key :id
      String :user, null: false
    end
  end
end
