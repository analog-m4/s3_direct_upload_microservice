class AddAttributesToUploadedFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :uploaded_files, :file_name, :string
    add_column :uploaded_files, :s3_key, :string
    add_column :uploaded_files, :content_type, :string
    add_column :uploaded_files, :file_size, :integer
  end
end