ActiveAdmin.register IssueType do
  menu parent: 'Settings', priority: 5, label: 'Support issue types'
  permit_params :name
end
