# Store64

'Store 64' is a fictitious video game e-commerce platform. Site visitors can log in as a User, Merchant, or Admin. Users and visitors can add items to a cart. Users can 'checkout' their cart to create an order. Merchants can fulfill items in an order, and admins can access functionality of both users and merchants.

# Prerequisites

- Requires PostgreSQL database

# Getting Started

Clone the repo on your local machine from your terminal

    git clone https://github.com/csvlewis/little_shop.git

Enter the newly created directory and run bundle install and bundle

    cd little_shop
    bundle

Create, migrate, and seed the database

    rake db:{create,migrate,seed}

Launch a local server with rails s

    rails s

Navigate to 'localhost:3000' in your internet browser

![localhost:3000](/localhost.png?raw=true)

Once you reach the site you can access login, registration, and other visitor functionality via the navigation bar at the top of the screen.

![Navigation Bar](/navigation_bar.png?raw=true)

# User Login

You can log in as a default admin with the following credentials:

email: admin@gmail.com password: 'password'

Login information for various other users and merchants already in the database can be found in the db/seeds.rb file as seen below:

![Login Data](/login_data.png?raw=true)

New users can be created through the 'Register' link in the navigation bar.

Admins can upgrade normal users to merchants via the user's profile page. They can also downgrade merchants to regular users via the merchant's dashboard page.

# Database Visualization

![Database Visualization](/database_schema.png?raw=true)

# How to Test

Store64 uses RSpec for testing. To run the full test suite, simply run 'rspec' from the terminal.

    rspec

Individual tests can be run by specifying the desired file path and line number. For example,

    rspec spec/models/item_spec.rb:65

will run the item model test that is found in that file on line 65.

# Live Site
- http://little-shop.lapicola.com/

# Built With

- Ruby on Rails Framework
- [Waffle.io](https://waffle.io/plapicola/little_shop)

# Authors

- [Tim Allen](https://github.com/timnallen)
- [Teresa Knowles](https://github.com/teresa-m-knowles)
- [Peter Lapicola](https://github.com/plapicola)
- [Chris Lewis](https://github.com/csvlewis)
