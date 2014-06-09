class RemoveProjectFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :Project, :string
  end
end
