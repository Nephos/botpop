Sequel.migration do
  change do
    create_table(:points) do
      # primary_key :id
      String    :assigned_to
      String    :assigned_by
      String    :type
      DateTime  :created_at
    end
  end
end
