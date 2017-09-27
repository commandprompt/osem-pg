# app/decorators/refinery/admin_controller_decorator.rb

module RefineryAdminControllerAuthenticationDecorator
  protected

  def authenticate_refinery_user!
    authenticate_user!
  end

  def current_refinery_user
    current_user
  end
end

module Refinery
  module SiteBarHelper
    def display_site_bar?
      user_signed_in?
    end
  end
end

Refinery::AdminController.send :prepend, RefineryAdminControllerAuthenticationDecorator