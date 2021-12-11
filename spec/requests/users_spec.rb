require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:valid_attributes) do
    { user: {
      name: "Blessed",
      email: "blessed@example.com",
      password: "1234pass",
    } }
  end

  let!(:invalid_attributes) do
    { user: {
      name: "B",
      email: "blessed@example.com",
    } }
  end

  def get_link_by_text(html_body, text)
    doc = Nokogiri::HTML(html_body.encoded)

    loop do
      children = doc.children
      break if children.empty?

      if children.length == 1 &&
         children.first.text == text &&
         children.first.parent.name = "a"
        return children.first.parent
      end

      doc = children
    end
  end

  def check_confirmation_email_for(user)
    perform_enqueued_jobs

    email = find_email(user.email)
    expect(email).not_to be_nil
    expect(email.subject).to eq "Confirmation instructions"

    confirmation_link = get_link_by_text(email.body, "Confirm my account")
    expect(confirmation_link).to_not be_nil

    confirmation_url = confirmation_link.attributes["href"].value

    expect(user.reload.confirmed?).to be_falsey
    get confirmation_url, xhr: true
    expect(user.reload.confirmed?).to be_truthy
  end

  describe "POST /api/login" do
    context "wrong credentials" do
      it "returns 401 unauthorized" do
        post "/api/login", xhr: true, params: {
                             user: {
                               email: "some-random-email@example.com",
                               password: "very wrong password",
                             },
                           }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "correct credentials but unconfirmed user" do
      it "returns 401 unauthorized" do
        user = create :user, :unconfirmed
        post "/api/login", xhr: true, params: {
                             user: {
                               email: user.email,
                               password: user.password,
                             },
                           }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "correct credentials" do
      it "returns 201 response" do
        user = create :user
        post "/api/login", xhr: true, params: {
                             user: {
                               email: user.email,
                               password: user.password,
                             },
                           }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "GET /users" do
    before do
      create_list :user, rand((rand(2..3) * User.per_page)..(rand(4..6) * User.per_page))
      get "/users", xhr: true
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns a paginated list of users without email addresses" do
      expect(json["data"].length <= User.per_page).to be_truthy
      expect(json["_pagination"]).not_to be_nil
      expect(json["_pagination"]["count"] <= User.per_page).to be_truthy
      expect(json["_pagination"]["total_count"]).to eq User.count
      expect(json["_links"]["next_page"]).not_to be_nil
      expect(json["_links"]).not_to be_nil
      total_pages = (User.count.to_f / User.per_page).ceil
      expect(json["_pagination"]["total_pages"]).to eq total_pages
      expect(json["data"][rand(User.per_page)]["email"]).to be_nil
      expect(json["data"][rand(User.per_page)]["name"]).not_to be_nil
    end

    it "orders results in ascending order of creation time" do
      expect(json["data"][0]["id"] < json["data"][-1]["id"]).to be_truthy
    end
  end

  describe "PUT /users/:id/follow" do
    let(:user) { create :user }

    context "authenticated user" do
      before do
        @token = token_for(user)
      end

      it "follows user" do
        user2 = create :user
        put follow_user_url(user2),
            xhr: true,
            headers: { 'Authorization': @token }
        expect(user2.reload.followers).to include(user)
        expect(user.reload.following).to include(user2)
      end
    end

    context "un-authenticated user" do
      it "returns 401 unauthorized" do
        put follow_user_url(user), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /users/:id/unfollow" do
    let(:user) { create :user }

    context "authenticated user" do
      before do
        @token = token_for(user)
      end

      it "un-follows user" do
        user2 = create :user
        user2.followers << user
        expect(user2.reload.followers).to include(user)
        expect(user.reload.following).to include(user2)
        put unfollow_user_url(user2),
            xhr: true,
            headers: { 'Authorization': @token }
        expect(user2.reload.followers).to_not include(user)
        expect(user.reload.following).to_not include(user2)
      end
    end

    context "un-authenticated user" do
      it "returns 401 unauthorized" do
        put unfollow_user_url(user), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /users/:id" do
    let!(:user) { create :user }

    context "authenticated user" do
      it "returns user email" do
        @token = token_for(user)
        get "/users/#{user.id}",
            xhr: true,
            headers: { 'Authorization': @token }
        expect(json["email"]).not_to be_nil
        expect(response).to have_http_status(:success)
      end

      context "user with followers/following" do
        before do
          random_count1 = rand((rand(1..3) * User.per_page)..(rand(5..8) * User.per_page))
          user.followers << create_list(:user, random_count1)

          random_count2 = rand((rand(1..3) * User.per_page)..(rand(5..8) * User.per_page))
          user.following << create_list(:user, random_count2)

          token = token_for(create :user)
          @opts = { xhr: true, headers: { 'Authorization': token } }
          get "/users/#{user.id}", **@opts
        end

        it "returns paginated list of followers" do
          expect(json["followers"]["data"].length).to eq(User.per_page)
          expect(json["followers"]["_links"]["next_page"]).to eq(user_url(user, followers_page: 2))
          total_followers_page = (user.followers.count / User.per_page.to_f).ceil
          expect(json["followers"]["_links"]["last_page"]).to eq(user_url(user, followers_page: total_followers_page))
          get json["followers"]["_links"]["next_page"], **@opts
          expect(json["followers"]["_links"]["prev_page"]).to eq(user_url(user, followers_page: 1))
          expect(json["followers"]["_links"]["url"]).to eq(user_url(user, followers_page: 2))
          get json["followers"]["_links"]["last_page"], **@opts
          expect(json["followers"]["_links"]["first_page"]).to eq(user_url(user, followers_page: 1))
          expect(json["followers"]["_links"]["next_page"]).to be_nil
        end

        it "returns paginated list of following" do
          expect(json["following"]["data"].length).to eq(User.per_page)
          expect(json["following"]["_links"]["next_page"]).to eq(user_url(user, following_page: 2))
          total_following_page = (user.following.count / User.per_page.to_f).ceil
          expect(json["following"]["_links"]["last_page"]).to eq(user_url(user, following_page: total_following_page))
          get json["following"]["_links"]["next_page"], **@opts
          expect(json["following"]["_links"]["prev_page"]).to eq(user_url(user, following_page: 1))
          expect(json["following"]["_links"]["url"]).to eq(user_url(user, following_page: 2))
          get json["following"]["_links"]["last_page"], **@opts
          expect(json["following"]["_links"]["first_page"]).to eq(user_url(user, following_page: 1))
          expect(json["following"]["_links"]["next_page"]).to be_nil
        end
      end

      context "with about info" do
        it "displays user about" do
          user = create :user, about: "This is my information"
          @opts = { xhr: true, headers: { 'Authorization': token_for(create :user) } }
          get "/users/#{user.id}", **@opts
          expect(json["about"]).to eq user.about
        end
      end

      context "with posts" do
        before do
          random_count = rand((rand(1..3) * Post.per_page)..(rand(5..8) * Post.per_page))
          create_list(:post, random_count, user: user)

          token = token_for(create :user)
          @opts = { xhr: true, headers: { 'Authorization': token } }
          get "/users/#{user.id}", **@opts
        end

        it "returns paginated list of user's posts in descending order of creation" do
          # check descending order
          expect(json["posts"]["data"][0]["id"] > json["posts"]["data"][-1]["id"]).to be_truthy

          expect(json["posts"]["data"].length).to eq(Post.per_page)
          expect(json["posts"]["_pagination"]["count"] <= Post.per_page).to be_truthy
          expect(json["posts"]["_pagination"]["total_count"]).to eq(user.posts.count)
          expect(json["posts"]["_links"]["next_page"]).to eq(user_url(user, posts_page: 2))
          total_posts_page = (user.posts.count / Post.per_page.to_f).ceil
          expect(json["posts"]["_links"]["last_page"]).to eq(user_url(user, posts_page: total_posts_page))
          get json["posts"]["_links"]["next_page"], **@opts
          expect(json["posts"]["_links"]["prev_page"]).to eq(user_url(user, posts_page: 1))
          expect(json["posts"]["_links"]["url"]).to eq(user_url(user, posts_page: 2))
          get json["posts"]["_links"]["last_page"], **@opts
          expect(json["posts"]["_links"]["first_page"]).to eq(user_url(user, posts_page: 1))
          expect(json["posts"]["_links"]["next_page"]).to be_nil
        end
      end
    end

    context "un-authenticated user" do
      it "returns unauthorized" do
        get "/users/#{User.all.sample.id}", xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /users/:id/followers" do
    let!(:user) { create :user }
    context "unauthenticated user" do
      it "returns 401 unauthorized" do
        get followers_user_url(user), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "authenticated user" do
      it "should return a successful response" do
        get followers_user_url(user), xhr: true, headers: { 'Authorization': token_for(create :user) }
        expect(response).to have_http_status(:ok)
      end

      it "returns a paginated list of followers (without email addresses) in ascending order" do
        random_count1 = rand((rand(3..5) * User.per_page)..(rand(6..8) * User.per_page))
        users = create_list :user, random_count1
        user.followers << users.sample(random_count1 / 2)

        get followers_user_url(user), xhr: true, headers: { 'Authorization': token_for(create :user) }

        expect(json["data"].length <= User.per_page).to be_truthy
        expect(json["_pagination"]).not_to be_nil
        expect(json["_pagination"]["count"] <= User.per_page).to be_truthy
        expect(json["_pagination"]["total_count"]).to eq user.followers.count
        expect(json["_links"]["next_page"]).not_to be_nil
        expect(json["_links"]).not_to be_nil
        total_pages = (user.followers.count.to_f / User.per_page).ceil
        expect(json["_pagination"]["total_pages"]).to eq total_pages
        expect(json["data"][rand(User.per_page)]["email"]).to be_nil
        expect(json["data"][rand(User.per_page)]["name"]).not_to be_nil

        expect(json["data"][0]["id"] < json["data"][-1]["id"]).to be_truthy
      end
    end
  end

  describe "GET /users/:id/following" do
    let!(:user) { create :user }
    context "unauthenticated user" do
      it "returns 401 unauthorized" do
        get following_user_url(user), xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
    context "authenticated user" do
      it "should return a successful response" do
        get following_user_url(user), xhr: true, headers: { 'Authorization': token_for(create :user) }
        expect(response).to have_http_status(:ok)
      end

      it "returns a paginated list of following (without email addresses) in ascending order" do
        random_count1 = rand((rand(3..5) * User.per_page)..(rand(6..8) * User.per_page))
        users = create_list :user, random_count1
        user.following << users.sample(random_count1 / 2)

        get following_user_url(user), xhr: true, headers: { 'Authorization': token_for(create :user) }

        expect(json["data"].length <= User.per_page).to be_truthy
        expect(json["_pagination"]).not_to be_nil
        expect(json["_pagination"]["count"] <= User.per_page).to be_truthy
        expect(json["_pagination"]["total_count"]).to eq user.following.count
        expect(json["_links"]["next_page"]).to eq following_user_url(page: 2)
        expect(json["_links"]["current_page"]).to eq following_user_url(page: 1)

        total_pages = (user.following.count.to_f / User.per_page).ceil
        expect(json["_pagination"]["total_pages"]).to eq total_pages
        expect(json["data"][rand(User.per_page)]["email"]).to be_nil
        expect(json["data"][rand(User.per_page)]["name"]).not_to be_nil

        expect(json["data"][0]["id"] < json["data"][-1]["id"]).to be_truthy
      end
    end
  end

  describe "POST /confirmation" do
    context "for unconfirmed user" do
      it "resends account confirmation email" do
        user = create :user, :unconfirmed
        post "/confirmation", xhr: true, params: { user: { email: user.email } }
        check_confirmation_email_for user
      end
    end

    context "for confirmed user" do
      let(:user) { create :user }

      before do
        post "/confirmation", xhr: true, params: { user: { email: user.email } }
      end

      it "does not send confirmation email" do
        expect(find_email(user.email)).to be_nil
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns helpful error message" do
        expect(json["errors"]["email"]).to eq ["was already confirmed, please try signing in"]
      end
    end
  end

  describe "GET /users/me" do
    context "un-authenticated user" do
      it "returns unauthorized" do
        get me_users_url, xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "authenticated user" do
      let!(:user) { create :user }

      it "returns the current user" do
        @token = token_for(user)
        get me_users_url, xhr: true, headers: { 'Authorization': @token }
        expect(json["email"]).to eq user.email
        expect(json["name"]).to eq user.name
        expect(json["about"]).to eq user.about
        expect(json["id"]).to eq user.id
      end

      context "user with followers/following" do
        before do
          random_count1 = rand((rand(1..3) * User.per_page)..(rand(5..8) * User.per_page))
          user.followers << create_list(:user, random_count1)

          random_count2 = rand((rand(1..3) * User.per_page)..(rand(5..8) * User.per_page))
          user.following << create_list(:user, random_count2)

          @opts = { xhr: true, headers: { 'Authorization': token_for(user) } }
          get me_users_url, **@opts
        end

        it "returns paginated list of followers" do
          expect(json["followers"]["data"].length).to eq(User.per_page)
          expect(json["followers"]["_links"]["next_page"]).to eq(user_url(user, followers_page: 2))
          total_followers_page = (user.followers.count / User.per_page.to_f).ceil
          expect(json["followers"]["_links"]["last_page"]).to eq(user_url(user, followers_page: total_followers_page))
          get json["followers"]["_links"]["next_page"], **@opts
          expect(json["followers"]["_links"]["prev_page"]).to eq(user_url(user, followers_page: 1))
          expect(json["followers"]["_links"]["url"]).to eq(user_url(user, followers_page: 2))
          get json["followers"]["_links"]["last_page"], **@opts
          expect(json["followers"]["_links"]["first_page"]).to eq(user_url(user, followers_page: 1))
          expect(json["followers"]["_links"]["next_page"]).to be_nil
        end

        it "returns paginated list of following" do
          expect(json["following"]["data"].length).to eq(User.per_page)
          expect(json["following"]["_links"]["next_page"]).to eq(user_url(user, following_page: 2))
          total_following_page = (user.following.count / User.per_page.to_f).ceil
          expect(json["following"]["_links"]["last_page"]).to eq(user_url(user, following_page: total_following_page))
          get json["following"]["_links"]["next_page"], **@opts
          expect(json["following"]["_links"]["prev_page"]).to eq(user_url(user, following_page: 1))
          expect(json["following"]["_links"]["url"]).to eq(user_url(user, following_page: 2))
          get json["following"]["_links"]["last_page"], **@opts
          expect(json["following"]["_links"]["first_page"]).to eq(user_url(user, following_page: 1))
          expect(json["following"]["_links"]["next_page"]).to be_nil
        end
      end

      context "with posts" do
        before do
          random_count = rand((rand(1..3) * Post.per_page)..(rand(5..8) * Post.per_page))
          create_list(:post, random_count, user: user)

          @opts = { xhr: true, headers: { 'Authorization': token_for(user) } }
          get me_users_url, **@opts
        end

        it "returns paginated list of user's posts in descending order of creation" do
          # check descending order
          expect(json["posts"]["data"][0]["id"] > json["posts"]["data"][-1]["id"]).to be_truthy

          expect(json["posts"]["data"].length).to eq(Post.per_page)
          expect(json["posts"]["_pagination"]["count"] <= Post.per_page).to be_truthy
          expect(json["posts"]["_pagination"]["total_count"]).to eq(user.posts.count)
          expect(json["posts"]["_links"]["next_page"]).to eq(user_url(user, posts_page: 2))
          total_posts_page = (user.posts.count / Post.per_page.to_f).ceil
          expect(json["posts"]["_links"]["last_page"]).to eq(user_url(user, posts_page: total_posts_page))
          get json["posts"]["_links"]["next_page"], **@opts
          expect(json["posts"]["_links"]["prev_page"]).to eq(user_url(user, posts_page: 1))
          expect(json["posts"]["_links"]["url"]).to eq(user_url(user, posts_page: 2))
          get json["posts"]["_links"]["last_page"], **@opts
          expect(json["posts"]["_links"]["first_page"]).to eq(user_url(user, posts_page: 1))
          expect(json["posts"]["_links"]["next_page"]).to be_nil
        end
      end
    end
  end

  describe "GET /users/find_people" do
    it "returns 401 unauthorized when user is unauthenticated" do
      get find_people_users_url, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated user" do
      let!(:user) { create :user }
      let!(:user1) { create :user }
      let!(:user2) { create :user }
      let!(:user3) { create :user }

      before do
        user.following << user2
        create_list :user, rand((2 * User.per_page)..(4 * User.per_page))

        @token = token_for(user)
        get find_people_users_url, as: :json, headers: { 'Authorization': @token }
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:success)
      end

      it "returns list of unfollowed users" do
        expect(json["data"][0]["name"]).to eq user1.name
        expect(json["data"][1]["name"]).to eq user3.name
      end

      it "paginates list of unfollowed users (without email addresses)" do
        expect(json["data"].length <= User.per_page).to be_truthy
        expect(json["_pagination"]).not_to be_nil
        expect(json["_pagination"]["count"] <= User.per_page).to be_truthy
        expect(json["_pagination"]["page"]).to eq 1
        expect(json["_pagination"]["total_count"]).to eq user.who_to_follow.count
        expect(json["_links"]["next_page"]).not_to be_nil
        expect(json["_links"]).not_to be_nil
        total_pages = (user.who_to_follow.count.to_f / User.per_page).ceil
        expect(json["_pagination"]["total_pages"]).to eq total_pages
        expect(json["data"][rand(User.per_page)]["email"]).to be_nil
        expect(json["data"][rand(User.per_page)]["name"]).not_to be_nil

        get json["_links"]["next_page"], as: :json, headers: { 'Authorization': @token }
        expect(json["_pagination"]["page"]).to eq 2

        get json["_links"]["last_page"], as: :json, headers: { 'Authorization': @token }
        expect(json["_pagination"]["page"]).to eq total_pages
      end
    end
  end

  describe "POST /api/signup" do
    context "with valid attributes" do
      it "creates new user" do
        expect {
          post "/api/signup", xhr: true, params: valid_attributes
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
      end

      it "sends account confirmation email" do
        post "/api/signup", xhr: true, params: valid_attributes
        user = User.find_by_email valid_attributes[:user][:email]
        check_confirmation_email_for user
      end
    end

    context "with invalid attributes" do
      it "does not create new user" do
        expect {
          post "/api/signup", xhr: true, params: invalid_attributes
        }.to_not change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /api/signup" do
    let!(:user) { create :user }

    context "authenticated user" do
      before do
        @token = token_for(user)
      end

      context "with valid attributes" do
        it "updates user details" do
          valid_attributes[:user][:current_password] = "my-secret"
          valid_attributes[:user][:avatar_image] = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/user.jpg")
          expect(user.avatar_image.persisted?).to be_nil
          put "/api/signup", xhr: true, params: valid_attributes, headers: { 'Authorization': @token }
          expect(user.reload.name).to eq valid_attributes[:user][:name]
          expect(user.avatar_image.persisted?).to_not be_nil
          expect(response).to have_http_status(:success)
        end

        context "with about" do
          it "updates the user about info" do
            valid_attributes[:user][:current_password] = "my-secret"
            valid_attributes[:user][:about] = "This is my about"
            put "/api/signup", xhr: true, params: valid_attributes, headers: { 'Authorization': @token }
            expect(user.reload.about).to eq valid_attributes[:user][:about]
          end
        end
      end

      context "with valid attributes but missing current_password" do
        it "does not update user details" do
          put "/api/signup", xhr: true, params: valid_attributes, headers: { 'Authorization': @token }
          expect(user.reload.name).to_not eq valid_attributes[:user][:name]
        end
      end

      context "with invalid attributes" do
        it "does not update user details" do
          put "/api/signup", xhr: true, params: invalid_attributes, headers: { 'Authorization': @token }
          expect(user.reload.email).to_not eq invalid_attributes[:user][:email]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "un-authenticated user" do
      it "returns unauthorized" do
        put "/api/signup", xhr: true
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/logout" do
    let!(:user) { create :user }

    before do
      @token = token_for(user)
    end

    it "returns no-content" do
      delete "/api/logout", xhr: true, headers: { 'Authorization': @token }
      expect(response).to have_http_status(:no_content)
    end

    it "revokes the token" do
      delete "/api/logout", xhr: true, headers: { 'Authorization': @token }
      get "/users/#{user.id}",
          xhr: true,
          headers: { 'Authorization': @token }
      expect(response.body).to eq "revoked token"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
