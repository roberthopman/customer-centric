class ApplicationController < ActionController::Base  
  protect_from_forgery with: :null_session

  def index    
  end

  def stripe_public_key
    render json: {'publicKey': Rails.configuration.stripe[:publishable_key]}
  end

  def create_setup_intent
    customer = Stripe::Customer.create
    data = Stripe::SetupIntent.create(customer: customer['id'])
    render json: data
  end

  def webhook
    # You can use webhooks to receive information about asynchronous payment events.
    # For more about our webhook events check out https://stripe.com/docs/webhooks.
    webhook_secret = Rails.configuration.stripe[:webhook_secret]
    
    payload = request.body.read
    if !webhook_secret.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, webhook_secret
        )
      rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        puts '⚠️  Webhook signature verification failed.'
        status 400
        return
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)
    end
    # Get the type of webhook event sent - used to check the status of SetupIntents.
    event_type = event['type']
    data = event['data']
    data_object = data['object']

    if event_type == 'setup_intent.created'
      puts '🔔 A new SetupIntent was created.'
    end

    if event_type == 'setup_intent.setup_failed'
      puts '🔔  A SetupIntent has failed the attempt to set up a PaymentMethod.'
    end

    if event_type == 'setup_intent.succeeded'
      puts '🔔 A SetupIntent has successfully set up a PaymentMethod for future use.'
    end

    if event_type == 'payment_method.attached'
      puts '🔔 A PaymentMethod has successfully been saved to a Customer.'

      # At this point, associate the ID of the Customer object with your
      # own internal representation of a customer, if you have one.

      # Optional: update the Customer billing information with billing details from the PaymentMethod
      customer = Stripe::Customer.update(
        data_object['customer'],
        email: data_object['billing_details']['email']
      )

      puts "🔔 Customer #{customer['id']} successfully updated."

      # You can also attach a PaymentMethod to an existing Customer
      # https://stripe.com/docs/api/payment_methods/attach
    end

    render json: {status: 'success'}
  end
end
