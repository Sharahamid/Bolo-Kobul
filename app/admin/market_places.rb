ActiveAdmin.register MarketPlace do
  menu parent: 'Wedding Shopping', priority: 1, label: 'Listings'

  permit_params :name , :status, :cost, :costing_unit, :facility, :link,
                :policy, :experience, :about, :service_coverage, :image, :image2, :image3, :location, :market_place_type_id,
                :contact_name, :contact_phone, :contact_email, :listed_until

  scope :all, default: true
  scope('Waiting for approval (paid)') { |s| s.pending.where.not(paid_at: nil) }
  scope('Not paid') { |s| s.pending.where(submitted_online: true, paid_at: nil) }
  scope('Live') { |s| s.live }
  scope('Ended') { |s| s.approved.where('listed_until <= ?', Time.current) }

  index do
    selectable_column
    id_column
    column :name
    column :market_place_type
    column :location
    column :status do |m|
      status_tag(m.status, class: m.approved? ? 'yes' : 'no')
    end
    column('Applied online') { |m| m.submitted_online? ? 'Yes' : '' }
    column('Paid') do |m|
      if m.paid?
        "Paid #{m.paid_at.in_time_zone('Dhaka').strftime('%-d %b %Y')}"
      elsif m.submitted_online?
        status_tag('Not paid', class: 'no')
      end
    end
    column('Listed until') do |m|
      next '' unless m.listed_until
      text = m.listed_until.strftime('%-d %b %Y')
      m.days_left <= 0 ? "#{text} (ended)" : "#{text} (#{m.days_left} days left)"
    end
    column :created_at
    actions
  end

  filter :name
  filter :market_place_type
  filter :location
  filter :status, as: :select, collection: MarketPlace.statuses
  filter :submitted_online
  filter :contact_phone
  filter :contact_email
  filter :created_at

  show do
    attributes_table do
      row :name, as: :string
      row :location, as: :string
      row :status, as: :string
      row :market_place_type
      row :cost, as: :string
      row :costing_unit, as: :string
      row :facility, as: :text
      row :policy, as: :text
      row :experience, as: :text
      row :about, as: :text
      row :link, as: :link
      row('Image') { |m| admin_image_or_none(m, :image) }
      row('Image 2') { |m| admin_image_or_none(m, :image2) }
      row('Image 3') { |m| admin_image_or_none(m, :image3) }
    end
    if resource.submitted_online? || resource.contact_phone.present?
      panel 'Application (only you see this)' do
        attributes_table_for resource do
          row :contact_name
          row :contact_phone
          row :contact_email
          row('Applied online') { |m| m.submitted_online? ? 'Yes' : 'No' }
          row('Paid') { |m| m.paid? ? "Yes, #{m.paid_at.in_time_zone('Dhaka').strftime('%-d %b %Y, %-I:%M %p')}" : 'No' }
          row('Payment') do |m|
            o = m.orders.order(:id).last
            o ? "৳#{o.total_amount.to_i} – #{o.status} – #{o.txn_no}" : '-'
          end
          row('Listed until') { |m| m.listed_until ? m.listed_until.strftime('%-d %b %Y') : 'Starts when you approve it (1 year)' }
          row('Renewal reminder sent') { |m| m.reminder_sent_at&.in_time_zone('Dhaka')&.strftime('%-d %b %Y') || '-' }
        end
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :name, as: :string
      input :status, as: :select, hint: 'Set to Approved to put it on the site. A paid online listing then stays up for 1 year and the business gets an email.'
      input :market_place_type
      input :cost, as: :number
      input :costing_unit, as: :string
      input :location, as: :select, collection: District&.all&.map{|d| ["#{d&.name&.humanize}", d.name]}
      input :facility, as: :text
      input :policy, as: :text
      input :experience, as: :text
      input :about, as: :text
      input :link, as: :string
      input :image, as: :file, label: 'Image (main)', hint: admin_image_hint(f.object, :image)
      input :image2, as: :file, label: 'Image 2', hint: admin_image_hint(f.object, :image2)
      input :image3, as: :file, label: 'Image 3', hint: admin_image_hint(f.object, :image3)
    end
    f.inputs 'Business contact and listing period' do
      input :contact_name
      input :contact_phone
      input :contact_email
      input :listed_until, as: :datepicker, hint: 'Leave empty for no end date. Change it to extend a listing (e.g. after renewal).'
    end
    f.actions
  end
end
