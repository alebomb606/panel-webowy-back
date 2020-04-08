module ApplicationHelper
  def check_icon_class(state)
    return 'fa fa-check' if state

    'fa fa-times'
  end
end
