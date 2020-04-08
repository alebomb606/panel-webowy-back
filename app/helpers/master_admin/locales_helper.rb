module MasterAdmin::LocalesHelper
  def locales_to_select(locales)
    locales.keys.map { |locale| [I18n.t("languages.#{locale}"), locale] }
  end
end
