class Api::V1::Trailers::AccessPermissions::FetchQuery < AppCommand
  def call(auth, trailer_id)
    permission = Try(ActiveRecord::RecordNotFound) do
      auth
        .logistician
        .trailer_access_permissions
        .joins(:trailer)
        .merge(::Trailer.active)
        .find_by!(trailer_id: trailer_id)
    end
    permission.or { Failure(what: :trailer_not_found) }
  end
end
