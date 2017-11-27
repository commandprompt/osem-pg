module Portal
  class BaseController < ApplicationController
    before_filter :verify_user

    def verify_user
      if (current_user.nil?)
        redirect_to sign_in_path
        return false
      end

      if (!current_user.sponsor)
        raise CanCan::AccessDenied.new('You are not authorized to access this area!')
      end
    end

    def check_user_privs
      return unless @sponsor.id != current_user.sponsor.id
      redirect_to portal_sponsor_path(current_user.sponsor.short_name),
                  alert: 'You are not permitted to view that page'
    end

  end
end
