require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :email}
    it {should validate_presence_of :address}
    it {should validate_presence_of :city}
    it {should validate_presence_of :state}
    it {should validate_presence_of :zipcode}

    it {should validate_uniqueness_of(:email)}

    it {should validate_numericality_of(:zipcode)
        .only_integer
        }


    it {should validate_length_of(:name)
        .is_at_least(1)
    }

    it {should validate_length_of(:email)
        .is_at_least(1)
    }

    it {should validate_length_of(:address)
        .is_at_least(1)
    }

    it {should validate_length_of(:city)
        .is_at_least(1)
    }

    it {should validate_confirmation_of(:password)}

  end
  describe 'relationships' do
    it {should have_many :orders}
    it {should have_many :items}
  end

  describe 'instance methods' do
    before :each do
      @merchant = create(:merchant)
      @item_1 = create(:item, user: @merchant, quantity: 10)
      @item_2 = create(:item, user: @merchant, quantity: 10)
      @item_3 = create(:item, user: @merchant, quantity: 10)
      @item_4 = create(:item, user: @merchant, quantity: 10)
      @item_5 = create(:item, user: @merchant, quantity: 10)
      @item_6 = create(:item, user: @merchant, quantity: 10)
      @user_1 = create(:user, state: 'California', city: 'Los Angeles')
      @user_2 = create(:user, state: 'Florida', city: 'Wausau')
      @user_3 = create(:user, state: 'Wisconsin', city: 'Wausau')
      @user_4 = create(:user, state: 'Wisconsin', city: 'Green Bay')
      @order_1 = create(:order, user: @user_1, status: 'completed')
      @order_2 = create(:order, user: @user_2, status: 'completed')
      @order_3 = create(:order, user: @user_3, status: 'completed')
      @order_4 = create(:order, user: @user_3, status: 'completed')
      @order_5 = create(:order, user: @user_4, status: 'completed')
      create(:order_item, order: @order_1, item: @item_1, unit_price: 100, quantity: 1)
      create(:order_item, order: @order_2, item: @item_2, unit_price: 2, quantity: 2)
      create(:order_item, order: @order_2, item: @item_3, unit_price: 2, quantity: 3)
      create(:order_item, order: @order_3, item: @item_4, unit_price: 2, quantity: 3)
      create(:order_item, order: @order_4, item: @item_6, unit_price: 2, quantity: 4)
      create(:order_item, order: @order_5, item: @item_6, unit_price: 2, quantity: 1)
      create(:order_item, order: @order_2, item: @item_4, unit_price: 2, quantity: 1)
    end
    describe '.top_items_for_merchant(limit)' do
      it 'returns an array of the top # items sold by quantity and the quantity of each sold for a specific merchant' do
        expect(@merchant.top_items_for_merchant(5)).to eq([@item_6, @item_4, @item_3, @item_2, @item_1])
        expect(@merchant.top_items_for_merchant(5).first.total_quantity).to eq(5)
      end
    end

    describe '.items_sold_by_quantity' do
      it 'returns the total quantity of items sold for a specific merchant' do
        expect(@merchant.items_sold_by_quantity).to eq(15)
      end
    end

    describe '.items_sold_by_percentage' do
      it 'returns the total percentage of items sold for a specific merchant' do
        @item_6.update(quantity: 5)
        @item_4.update(quantity: 6)
        @item_3.update(quantity: 7)
        @item_2.update(quantity: 8)
        @item_1.update(quantity: 9)

        expect(@merchant.items_sold_by_percentage).to eq(0.25)
      end
    end

    describe '.top_states(limit)' do
      it 'returns an array of the top # states where the most items were sold by a specific merchant along with the quantity shipped to each state' do
        expect(@merchant.top_states(3).first.state).to eq('Wisconsin')
        expect(@merchant.top_states(3).first.state_quantity).to eq(8)
      end
    end

    describe '.top_cities(limit)' do
      it 'returns an array of the top # cities where the most items were sold by a specific merchant along with the quantity shipped to each city' do
        expect(@merchant.top_cities(3)[0].location).to eq('Wausau, Wisconsin')
        expect(@merchant.top_cities(3)[0].city_quantity).to eq(7)
      end
    end

    describe '.top_customer_by_orders' do
      it 'returns the user with the most orders containing a specific merchant\'s items, along with their total number of orders' do
        expect(@merchant.top_customer_by_orders.name).to eq(@user_3.name)
        expect(@merchant.top_customer_by_orders.order_count).to eq(2)
      end
    end

    describe '.top_customer_by_items' do
      it 'returns the user who has ordered the most items from a specific merchant, along with the total quantity of items ordered' do
        expect(@merchant.top_customer_by_items.name).to eq(@user_3.name)
        expect(@merchant.top_customer_by_items.item_count).to eq(7)
      end
    end

    describe '.top_spenders(limit)' do
      it 'returns the top 3 users who have spent the most money on a specific merchant\'s items, along with the total amount spent by each' do
        expect(@merchant.top_spenders(3).first.name).to eq(@user_1.name)
        expect(@merchant.top_spenders(3).first.total_spent).to eq(100)
      end
    end
  end

  describe 'class methods' do
    before :each do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)
      @merchant_3 = create(:merchant)
      @merchant_4 = create(:merchant)

      @user_1 = create(:user, state: 'California', city: 'Los Angeles')
      @user_2 = create(:user, state: 'Florida', city: 'Wausau')
      @user_3 = create(:user, state: 'Wisconsin', city: 'Wausau')
      @user_4 = create(:user, state: 'Wisconsin', city: 'Green Bay')
      @user_5 = create(:user, state: 'Colorado', city: 'Denver')


      @item_1 = create(:item, user: @merchant_1, quantity: 100, price: 30)
      @item_2 = create(:item, user: @merchant_1, quantity: 100, price: 20)
      @item_3 = create(:item, user: @merchant_2, quantity: 100, price: 17)
      @item_4 = create(:item, user: @merchant_3, quantity: 100, price: 5)
      @item_5 = create(:item, user: @merchant_4, quantity: 100, price: 3)
      @item_6 = create(:item, user: @merchant_2, quantity: 100, price: 3)


      @order_1 = create(:order, user: @user_1, status: 'completed')

      create(:order_item, order: @order_1, item: @item_1, unit_price: 30, quantity: 10, fulfilled: true, created_at: 60.seconds.ago, updated_at: 1.second.ago)
      create(:order_item, order: @order_1, item: @item_2, unit_price: 20, quantity: 10, fulfilled: true, created_at: 58.seconds.ago, updated_at: 1.second.ago)
      create(:order_item, order: @order_1, item: @item_6, unit_price: 3, quantity: 10, fulfilled: true, created_at: 31.seconds.ago, updated_at: 1.second.ago)
      #Order 1
      #Total: $530
      #From Merchant 1
      #Item 1  $30  10 = $300
      #Item 2 $20 10 = $200
      #Bought from Merchant 1 = $500
      #Took him about a minute to fulfill

      #From Merchant 2
      #Item 6 $3 10 - $30
      #Bought from Merchant 2 = $30
      #Took him 30 seconds to fulfill

      #Order 2
      #total: $340
      #From Merchant 2
      #Item 3 took him about
      #about 30 second to fulfill
      @order_2 = create(:order, user: @user_1, status: 'pending')

      create(:order_item, order: @order_2, item: @item_3, unit_price: 17, quantity: 20, fulfilled: true, created_at: 32.seconds.ago, updated_at: 1.second.ago)

      #Order 3
      #Total: $130
      #From Merchant 3 $100
      #Item 4 unit price: 5 quantity: 20
      #Took them 3 seconds to fulfill

      #From Merchant 4 $30
      #Item 5 unit price 3, quantity: 10
      #Took them 1 second to fulfill
      #

      @order_3 = create(:order, user: @user_1, status: 'completed')

      create(:order_item, order: @order_3, item: @item_4, unit_price: 5, quantity: 20, fulfilled: true, created_at: 4.seconds.ago, updated_at: 1.second.ago)
      create(:order_item, order: @order_3, item: @item_5, unit_price: 3, quantity: 10, fulfilled: true, created_at: 30.seconds.ago, updated_at: 29.seconds.ago)


    end
    it '.all_merchants' do
      merchants = [@merchant_1, @merchant_2, @merchant_3, @merchant_4]
      merchants << build(:inactive_merchant)
      merchants.last.save

      expect(User.all_merchants).to eq(merchants)
    end

    describe '.top_merchants_by_revenue' do
      it 'should return the top 3 merchants who have sold the most by price and quantity and their revenue' do

        expect(User.top_merchants_by_revenue).to eq([@merchant_1, @merchant_2, @merchant_3])
        expect(User.top_merchants_by_revenue[0].revenue).to eq(500)
        expect(User.top_merchants_by_revenue[1].revenue).to eq(370)
        expect(User.top_merchants_by_revenue[2].revenue).to eq(100)
      end
    end

    describe '.fastest_merchants' do
      it 'should return the top 3 merchants who were fastest at fulfilling items in an order, and their times' do
        #fastest merchants should be, in order: merchant_4, merchant_3, merchant_2
        expect(User.fastest_merchants).to eq([@merchant_4, @merchant_3, @merchant_2])
        expect(User.fastest_merchants[0].fulfillment_time[0..-8]).to eq("00:00:01")
        expect(User.fastest_merchants[1].fulfillment_time[0..-8]).to eq("00:00:03")
        expect(User.fastest_merchants[2].fulfillment_time[0..-8]).to eq("00:00:30")

      end


      it 'should return the worst 3 merchants who were slowest at fulfilling items in an order, and their times' do
        #slowest merchants should be, in order: merchant_1, merchant_2, merchant_3
        expect(User.slowest_merchants).to eq([@merchant_1, @merchant_2, @merchant_3])
        expect(User.slowest_merchants[0].fulfillment_time[0..7]).to eq("00:00:58")
        expect(User.slowest_merchants[1].fulfillment_time[0..7]).to eq("00:00:30")
        expect(User.slowest_merchants[2].fulfillment_time[0..7]).to eq("00:00:03")
      end
    end

    describe '.biggest_orders' do
      it 'should return the top 3 biggest orders by quantity of items shipped in an order, plus their quantities' do
        OrderItem.destroy_all
        Order.destroy_all

        order_1 = create(:order, user: @user_1, status: 'completed')
        create(:order_item, order: order_1, item: @item_1, fulfilled: true, quantity: 10)
        order_2 = create(:order, user: @user_1, status: 'completed')
        create(:order_item, order: order_2, item: @item_1, fulfilled: true, quantity: 8)
        order_3 = create(:order, user: @user_1, status: 'completed')
        create(:order_item, order: order_3, item: @item_1, fulfilled: true, quantity: 5)
        order_4 = create(:order, user: @user_1, status: 'completed')
        create(:order_item, order: order_4, item: @item_1, fulfilled: true, quantity: 2)

        expect(Order.biggest_orders).to eq([order_1, order_2, order_3])
        expect(Order.biggest_orders[0].total_quantity).to eq(10)
        expect(Order.biggest_orders[1].total_quantity).to eq(8)
        expect(Order.biggest_orders[2].total_quantity).to eq(5)
      end
    end
  end
end
