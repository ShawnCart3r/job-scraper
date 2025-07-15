class AddFieldsToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :description, :text
    add_column :jobs, :apply_url, :string
    add_column :jobs, :salary_min, :integer
    add_column :jobs, :salary_max, :integer
  end
end
