Sequel.migration do
  change do
    create_table(:messages) do
      primary_key :id
      String    :author
      String    :dest
      String    :content
      DateTime  :created_at
      DateTime  :read_at
    end
  end
end
