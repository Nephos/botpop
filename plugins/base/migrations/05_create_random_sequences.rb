Sequel.migration do
  change do
    create_table(:random_sentences) do
      primary_key :id
      String    :author
      String    :trigger
      String    :content
      Bool      :enabled, default: true
      DateTime  :created_at

      index :trigger, unique: true
    end
  end
end
