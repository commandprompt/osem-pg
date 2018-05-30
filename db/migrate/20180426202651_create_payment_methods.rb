class CreatePaymentMethods < ActiveRecord::Migration
  def self.up
    create_table :payment_methods do |t|
      t.references :conference, null: false
      t.string :environment, null: false
      t.string :gateway, null: false
	  t.string :braintree_environment
      t.string :braintree_merchant_id
      t.string :braintree_public_key
      t.string :braintree_private_key
      t.string :braintree_merchant_account
      t.string :payu_merchant_pos_id
      t.string :payu_signature_key
      t.string :stripe_publishable_key
      t.string :stripe_secret_key

      t.timestamps
    end

    add_index :payment_methods, [:conference_id, :environment], unique: true

    add_foreign_key :payment_methods, :conferences

  end

  def self.down
    drop_table :payment_methods
  end

end
