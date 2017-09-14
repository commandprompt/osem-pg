module MyApp::DeviseAuth
  def authenticate
    if current_user
      ability = Ability.new(current_user)
      return true if ability.can?(:manage, "Cms::Site")
      raise CanCan::AccessDenied
    else
      scope = Devise::Mapping.find_scope!(:user)
      session["#{scope}_return_to"] = new_cms_admin_site_path(:locale => I18n.locale) # if localized...
      redirect_to admin_sign_in_path
    end
  end
end
