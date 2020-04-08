class LogisticianPresenter < ApplicationPresenter
  delegate :email, to: :auth

  def full_name
    "#{person.first_name} #{person.last_name}"
  end

  def company
    person.company.name
  end
end
