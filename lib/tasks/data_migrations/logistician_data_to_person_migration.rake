namespace :data_migrations do
  desc 'Move basic data from Logistician to Person model' do
    task logistician_to_person: :environment do
      ActiveRecord::Base.transaction do
        ::Logistician.find_each do |logistician|
          logistician.create_person(
            first_name: logistician.first_name,
            last_name: logistician.last_name,
            phone_number: logistician.phone_number,
            extra_phone_number: logistician.extra_phone_number,
            email: logistician.auth.email,
            company: logistician.company
          )
        end
      end
    end
  end
end
