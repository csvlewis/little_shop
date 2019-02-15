require 'rails_helper'

RSpec.describe 'Merchant dashboard page' do
  before :each do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_1)
    @item_3 = create(:item, user: @merchant_2)
    @user = create(:user)
    @order_1 = create(:order, user: @user)
    create(:order_item, order: @order_1, item: @item_1, unit_price: 1, quantity: 1)
    create(:order_item, order: @order_1, item: @item_1, unit_price: 1, quantity: 1)
    @order_2 = create(:order, user: @user)
    create(:order_item, order: @order_2, item: @item_2, unit_price: 2, quantity: 2)
    @order_3 = create(:order, user: @user)
    create(:order_item, order: @order_3, item: @item_3, unit_price: 3, quantity: 3)
  end

  context 'as a merchant' do
    describe 'when I visit my merchant dashboard' do
      it 'I see my profile data, but cannot edit it' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

        visit merchant_user_path(@merchant_1)

        expect(page).to have_content("Username: #{@merchant_1.name}")
        expect(page).to have_content("Email: #{@merchant_1.email}")
        expect(page).to have_content("Address: #{@merchant_1.address}")
        expect(page).to have_content("City: #{@merchant_1.city}")
        expect(page).to have_content("State: #{@merchant_1.state}")
        expect(page).to have_content("Zip code: #{@merchant_1.zipcode}")
        expect(page).to_not have_link('Edit my profile')
      end

      it 'I see a list of pending orders containing items I sell' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

        visit merchant_user_path(@merchant_1)

        within "#order-#{@order_1.id}" do
          expect(page).to have_content("Order ID: #{@order_1.id}")
          expect(page).to have_content("Created on: #{@order_1.created_at.strftime("%m-%d-%Y")}")
          expect(page).to have_content("Total items: #{@order_1.total_items}")
          expect(page).to have_content("Amount: #{@order_1.merchant_items(@merchant)}")
        end

        within "#order-#{@order_2.id}" do
          expect(page).to have_content("Order ID: #{@order_2.id}")
          expect(page).to have_content("Created on: #{@order_2.created_at.strftime("%m-%d-%Y")}")
          expect(page).to have_content("Total items: #{@order_2.total_items}")
          expect(page).to have_content("Amount: #{@order_2.merchant_items(@merchant)}")
        end

        expect(page).to_not have_content("Order ID: #{@order_3.id}")

        click_link "#{@order_1.id}"

        expect(current_path).to eq(dashboard_orders_path(@order_1))
      end
    end
  end
end
