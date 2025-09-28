class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /auth
  def create
    build_resource(sign_up_params)

    if resource.save
      # IMPORTANT: pas de session !
      sign_in(resource, store: false)

      render json: { user: { id: resource.id, email: resource.email } }, status: :created
    else
      render json: { errors: resource.errors }, status: :unprocessable_entity
    end
  end
end
