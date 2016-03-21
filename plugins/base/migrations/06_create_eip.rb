Sequel.migration do
  change do
    create_table(:eips) do
      primary_key :id
      String    :author
      String    :title
      DateTime  :created_at
    end
  end
end
