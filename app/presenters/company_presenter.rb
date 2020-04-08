class CompanyPresenter < ApplicationPresenter
  attr_reader :company
  delegate :id, :email, :nip, :name, to: :company

  def initialize(company)
    @company = company
  end

  def address
    "#{@company.street}, #{@company.postal_code} #{@company.city}"
  end
end
