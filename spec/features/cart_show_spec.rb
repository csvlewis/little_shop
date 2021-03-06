require 'rails_helper'

RSpec.describe 'cart show page', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @item_1 = @merchant.items.create(name: "Thing 1", description: "It's a thing", image: "https://upload.wikimedia.org/wikipedia/en/5/53/Snoopy_Peanuts.png", price: 5.0, quantity: 2)
    @item_2 = @merchant.items.create(name: "Thing 2", description: "It's another thing", image: "https://upload.wikimedia.org/wikipedia/en/5/53/Snoopy_Peanuts.png", price: 7.0, quantity: 2)
  end
  it 'as a user or visitor with no items in my cart, I see a message that my cart is empty' do
    visit cart_path

    expect(page).to have_content("Your cart is empty.")
  end

  it 'it allows me to add items to the cart, shows me a flash message and changes the cart counter in my nav bar' do
    visit item_path(@item_1)

    click_on "Add to Shopping Cart"

    expect(current_path).to eq(items_path)
    expect(page).to have_content("You now have 1 copy of #{@item_1.name} in your cart!")
    expect(page).to have_content("Cart: 1")
  end

  it 'shows all items that I have added to my cart in the cart/s show page' do
    visit item_path(@item_1)
    click_on "Add to Shopping Cart"

    visit item_path(@item_1)
    click_on "Add to Shopping Cart"

    expect(page).to have_content("Cart: 2")

    click_on "Cart"

    expect(current_path).to eq(cart_path)
    expect(page).to have_content(@item_1.name)

    expect(page).to have_css("img[src*='#{@item_1.image}']")
    expect(page).to have_content(@merchant.name)
    expect(page).to have_content(@item_1.price)
    expect(page).to have_content("Quantity: 2")
    expect(page).to have_content("Subtotal: $10.00")
    expect(page).to have_content("Total: $10")

  end

  context "as a visitor" do
    it 'I don\'t see a button to checkout' do
      visit root_path
      click_on "Cart"

      expect(page).to_not have_button('Checkout')
    end

    describe "when I have items in my cart" do
      describe "and I visit the cart show page" do
        it "I see a message telling me to register or login in order to checkout" do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          click_on "Cart"

          expect(current_path).to eq(cart_path)

          expect(page).to have_content("You must login or register to checkout.")
          expect(page).to have_link("login", exact: true)
          expect(page).to have_link("register", exact: true)
        end

        it "I don't see the login or register message if I'm already logged in" do
          user = create(:user)
          login_as(user)

          visit item_path(@item_1)
          click_on "Add to Shopping Cart"
          click_on "Cart"

          expect(page).to_not have_content("You must login or register to checkout.")
          expect(page).to_not have_link("login")
          expect(page).to_not have_link("register")

        end

        it "I don't see the login or register message if I don't have items in my cart" do
          visit cart_path
          expect(page).to_not have_content("You must login or register to checkout.")
          expect(page).to_not have_link("login")
          expect(page).to_not have_link("register")
        end

        it "in the flash message, login is a path to login and register to register" do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          click_on "Cart"

          click_link("login")
          expect(current_path).to eq(login_path)

          click_on "Cart"

          expect(current_path).to eq(cart_path)
          click_on("register")

          expect(current_path).to eq(register_path)

          click_on "Cart"

          expect(page).to have_content("You must login or register to checkout.")
        end

        it 'I can click a button to remove all items from my cart' do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          visit item_path(@item_2)
          click_on "Add to Shopping Cart"

          click_on 'Cart'

          within "#item-#{@item_1.id}" do
            expect(page).to have_content("Quantity: 2")
          end

          click_button "Empty Cart"

          expect(page).to have_content("Your cart is empty.")
          expect(page).to have_content("Cart: 0")
          expect(page).to_not have_button("Empty Cart")

          expect(page).to_not have_css "#item-#{@item_1.id}"
          expect(page).to_not have_css "#item-#{@item_2.id}"
        end

        it 'I can remove a single item entirely from my cart' do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          visit item_path(@item_2)
          click_on "Add to Shopping Cart"

          click_on 'Cart'

          within "#item-#{@item_1.id}" do
            click_button 'Remove Item'
          end

          expect(page).to_not have_css "#item-#{@item_1.id}"
          expect(page).to have_css "#item-#{@item_2.id}"
        end

        it 'I see a button to increment the quantity of an item in my cart' do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          click_on 'Cart'

          within "#item-#{@item_1.id}" do
            click_button 'Increase Quantity'
          end

          within "#item-#{@item_1.id}" do
            expect(page).to have_content("Quantity: 2")
          end
        end

        it 'I cannot increment the quantity of an item beyond current stock' do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          click_on 'Cart'

          within "#item-#{@item_1.id}" do
            expect(page).to_not have_button('Increase Quantity')
          end
        end

        it 'I see a button to decrement the quantity of an item in my cart' do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          click_on 'Cart'

          within "#item-#{@item_1.id}" do
            click_button 'Decrease Quantity'
          end

          expect(page).to have_content("You now have 1 copy of #{@item_1.name} in your cart!")

          within "#item-#{@item_1.id}" do
            expect(page).to have_content('Quantity: 1')
          end
        end

        it 'decrementing the quantity to zero removes the item from my cart' do
          visit item_path(@item_1)
          click_on "Add to Shopping Cart"

          click_on 'Cart'

          within "#item-#{@item_1.id}" do
            click_button 'Decrease Quantity'
          end

          expect(page).to have_content("Your cart is empty.")

          expect(page).to_not have_css("#item-#{@item_1.id}")
        end
      end
    end
  end

  context 'as a registered user' do
    before :each do
      @user = create(:user)
      @merchant = create(:merchant)
      @item_1 = @merchant.items.create(name: "Thing 1", description: "It's a thing", image: "https://upload.wikimedia.org/wikipedia/en/5/53/Snoopy_Peanuts.png", price: 5.0, quantity: 1)
      @item_2 = create(:item, user: @merchant)
    end
    describe 'when my cart is empty' do
      it 'I don\'t see a button to checkout' do
        login_as(@user)
        click_link 'Cart'

        expect(page).to_not have_button('Checkout')

        visit item_path(@item_1)
        click_on "Add to Shopping Cart"
        click_link 'Cart'
        click_button 'Empty Cart'
        expect(page).to_not have_button('Checkout')
        expect(page).to_not have_button('Empty Cart')
      end
    end
    describe 'when I add items to my cart' do
      it 'and i visit my cart I can check out' do

        login_as(@user)

        visit item_path(@item_1)
        click_on "Add to Shopping Cart"

        visit item_path(@item_1)
        click_on "Add to Shopping Cart"

        visit item_path(@item_2)
        click_on "Add to Shopping Cart"

        click_on "Cart"

        expect(page).to have_button("Checkout")

        click_button "Checkout"

        expect(current_path).to eq(profile_orders_path)
        expect(page).to have_content("Your order was created!")

        expect(page).to have_content("pending")

        visit cart_path

        expect(page).to have_content("Your cart is empty.")
      end
    end
  end
end
