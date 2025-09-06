ActiveAdmin.register IssueType do
  menu parent: 'Manage Site', label: 'Customer issue types'
  permit_params :name
end
