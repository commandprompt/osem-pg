class PaymentsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  load_resource :conference, find_by: :short_title
  authorize_resource :conference_registrations, class: Registration
  before_action :init_payment_object

  def index
    @payments = current_user.payments
  end

  def new
    @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)
    @unpaid_ticket_purchases = current_user.ticket_purchases.unpaid.by_conference(@conference)
    @unpaid_quantity = Ticket.total_quantity(@conference, current_user, paid: false)
    gon.client_token = generate_client_token
  end

  def generate_client_token
    Braintree::ClientToken.generate
  end


  def create
   if @conference.payment_method.gateway == 'braintree'
      nonce = params[:payment_method_nonce]

      result = Braintree::Transaction.sale(
        :amount => Ticket.total_price(@conference, current_user, paid: false),
        :payment_method_nonce => nonce,
        :merchant_account_id => @conference.payment_method.braintree_merchant_account,
        :customer => {
            :email => current_user.email,
            :first_name => current_user.first_name,
            :last_name => current_user.last_name
        },
        :options => {
            :submit_for_settlement => true
        }

     )
      if result.success? == true
        @payment = Payment.new payment_params
        @payment.authorization_code = result.transaction.id
        @payment.amount = result.transaction.amount * 100 
        @payment.last4 = result.transaction.credit_card_details.last_4
        @payment.status = 1

        if @payment.save
          update_purchased_ticket_purchases
          redirect_to conference_physical_ticket_index_path,
                     notice: 'Thanks! Your ticket is booked successfully.'
        end
      else
        @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)
        @unpaid_quantity = Ticket.total_quantity(@conference, current_user, paid: false)
        @unpaid_ticket_purchases = current_user.ticket_purchases.unpaid.by_conference(@conference)
        @error_messages = result.errors.map { |error| "Error: #{error.code}: #{error.message}" }
        flash[:error] = result.message 
        render "new"
      end

   else
     @payment = Payment.new payment_params

     if @payment.purchase && @payment.save
       update_purchased_ticket_purchases
       redirect_to conference_physical_ticket_index_path, 
                   notice: 'Thanks! Your ticket is booked successfully.'
     else
       @total_amount_to_pay = Ticket.total_price(@conference, current_user, paid: false)
       @unpaid_quantity = Ticket.total_quantity(@conference, current_user, paid: false)
       @unpaid_ticket_purchases = current_user.ticket_purchases.unpaid.by_conference(@conference)
       flash[:error] = @payment.errors.full_messages.to_sentence + ' Please try again with correct credentials.'
     end
    end
  end


  def payment_params
    params.permit(:stripe_customer_email, :stripe_customer_token, :payment_method_nonce)
        .merge(stripe_customer_email: params[:stripeEmail],
               stripe_customer_token: params[:stripeToken],
               user: current_user, conference: @conference)
  end

  def update_purchased_ticket_purchases
    current_user.ticket_purchases.by_conference(@conference).unpaid.each do |ticket_purchase|
      ticket_purchase.pay(@payment, current_user)
    end
  end
  private

  def init_payment_object
    if @conference.payment_method.gateway == 'braintree'
      Braintree::Configuration.environment = @conference.payment_method.braintree_environment
      Braintree::Configuration.merchant_id = @conference.payment_method.braintree_merchant_id
      Braintree::Configuration.public_key = @conference.payment_method.braintree_public_key
      Braintree::Configuration.private_key = @conference.payment_method.braintree_private_key
    end
  end  
end
