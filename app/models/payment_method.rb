class PaymentMethod < ActiveRecord::Base
  belongs_to :conference

  GATEWAYS = [['Braintree', 'braintree'], ['PayU', 'payu'], ['Stripe', 'stripe']]

  default_scope { where(environment: Rails.env) }
end
