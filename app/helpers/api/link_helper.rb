module Api::LinkHelper
  include Kaminari::Helpers::UrlHelper

  def pagination_links(scope)
    {
      first: first_page_url(scope),
      last: last_page_url(scope),
      prev: prev_page_url(scope),
      next: next_page_url(scope)
    }.delete_if { |_, v| v.nil? }
  end

  def first_page_url(scope)
    "#{request.base_url}#{Kaminari::Helpers::FirstPage.new(self).url}" unless scope.empty?
  end

  def last_page_url(scope)
    return if scope.empty?

    "#{request.base_url}#{Kaminari::Helpers::LastPage.new(self, total_pages: scope.total_pages).url}"
  end
end
