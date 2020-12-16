# CustomerCentric

CustomerCentric is a tiny application to collect e-mail and creditcard details in Stripe.

# Local setup

```
bundle install
rails db:create
rails server
```

Add `.env` file in the current working directory with:
```
STRIPE_PUBLISHABLE_KEY=
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
```

# API versions

Stripe: 2020-08-27

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
