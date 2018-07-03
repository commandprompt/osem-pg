class Payment < ActiveRecord::Base
  has_many :ticket_purchases
  belongs_to :user
  belongs_to :conference

  attr_accessor :stripe_customer_email
  attr_accessor :stripe_customer_token
  attr_accessor :payment_method_nonce

  validates :status, presence: true
  validates :user_id, presence: true
  validates :conference_id, presence: true

  enum status: {
    unpaid: 0,
    success: 1,
    failure: 2,
    pending: 3,
    canceled: 4
  }

  def amount_to_pay
    Ticket.total_price(conference, user, paid: false).cents
  end

  def amount_as_money
    Money.new(amount, conference.default_currency)
  end

  def self.by_reference(ref)
    payment = Payment.where(reference: ref).first
    payment
  end
  
  def purchase
    if amount_to_pay > 0
      if @conference.payment_method.gateway == 'stripe'
        gateway_response = Stripe::Charge.create source: stripe_customer_token,
                                               receipt_email: stripe_customer_email,
                                               description: "ticket purchases(#{user.username})",
                                               amount: amount_to_pay,
                                               currency: conference.tickets.first.price_currency

        self.amount = gateway_response[:amount]
        self.last4 = gateway_response[:source][:last4]
        self.authorization_code = gateway_response[:id]
        self.status = 'success'
      end
    else
      self.amount = 0
      self.status = 'success'
    end

    true

  rescue Stripe::StripeError => error
    errors.add(:base, error.message)
    self.status = 'failure'
    false
  end
end
