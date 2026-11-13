ActiveAdmin.register SiteStat, as: 'Homepage numbers' do
  menu parent: 'Settings', priority: 8, label: 'Homepage numbers'
  config.filters = false
  permit_params :marriages_count
  actions :index, :edit, :update

  controller do
    # There is only one row: the menu opens its edit page straight away
    def index
      redirect_to edit_resource_path(SiteStat.current)
    end

    def update
      super do |success, _failure|
        success.html { redirect_to edit_resource_path(resource), notice: 'Saved. The homepage shows the new number straight away.' }
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Shown on the homepage' do
      f.input :marriages_count, label: 'Successful marriages (homepage)', min: 0,
              hint: 'Shown as "120+ successful marriages arranged so far" under the registration form. The + is added automatically: type only the number. Set 0 to hide it.'
    end
    f.actions { f.action :submit, label: 'Save' }
  end
end
