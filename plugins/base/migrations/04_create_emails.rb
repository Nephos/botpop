Sequel.migration do
  change do
    create_table(:emails) do
      primary_key :id
      String    :authname
      String    :address
      DateTime  :created_at
      Integer   :usage
      Bool      :primary, default: false

      index [:address], unique: true
    end
  end
end
