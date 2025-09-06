task :active_admin_managed_resources => :environment do
  skip_resources = [ 'Dashboard' ]

  namespace = ActiveAdmin.application.namespace(:shefali007)

  # pages     = namespace.resources.select { |r| r.is_a? ActiveAdmin::Page }
  resources = namespace.resources.select { |r| r.respond_to? :resource_class }

  resource_actions =
    resources.each_with_object({}) do |resource, actions|
      resource_name = resource.resource_class.name

      unless skip_resources.include? resource_name
        actions[resource_name] = resource.defined_actions
        actions[resource_name].concat [:read]
        actions[resource_name].concat resource.member_actions.map { |action| action.name }
        actions[resource_name].concat resource.collection_actions.map { |action| action.name }
        actions[resource_name].uniq!
      end
    end

  resource_actions.each do |resource_name, actions|
    actions.each do |action|
      managed_resource = ActiveAdmin::ManagedResource.find_or_create_by!(
        class_name: resource_name,
        action: action.to_s,
        name: "#{action.to_s} #{resource_name}"
      )

      puts "#{managed_resource.id}:#{managed_resource.name}"
    end
  end

  # pp resource_actions

  # page_actions =
  #   pages.each_with_object({}) do |page, actions|
  #     page_name = page.name
  #
  #     if !skip_resources.include? page_name
  #       actions[page_name] = page.page_actions + [:index]
  #     end
  #   end
  #
  # pp page_actions
end
