require "rails_helper"

RSpec.describe "Auth::Registrations", type: :request do
  let!(:user) { create :user }

  let!(:valid_attributes) do
    {
      name: "Blessed",
      email: "blessed@example.com",
      password: "1234pass",
    }
  end

  let!(:invalid_attributes) do
    {
      name: "B",
      email: "blessed@example.com",
    }
  end

  let(:valid_headers) do
    { 'Authorization': token_for(user) }
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

  describe "POST /api/signup" do
    context "with valid attributes" do
      it "creates new user" do
        expect {
          post "/api/signup", xhr: true, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:success)
      end

      it "sends account confirmation email" do
        post "/api/signup", xhr: true, params: { user: valid_attributes }
        user = User.find_by_email valid_attributes[:email]
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

  describe "PUT /api/signup" do
    let!(:user) { create :user }

    context "authenticated user" do
      before do
        @token = token_for(user)
      end

      context "with valid attributes" do
        it "updates user details and image (if given)" do
          valid_attributes[:current_password] = "my-secret"
          valid_attributes[:avatar_image] = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/user.jpg")
          expect(user.avatar_image.persisted?).to be_nil
          put "/api/signup", xhr: true,
                             params: { user: valid_attributes }, headers: valid_headers
          expect(user.reload.name).to eq valid_attributes[:name]
          expect(user.avatar_image.persisted?).to_not be_nil
          expect(response).to have_http_status(:success)
        end

        it "updates the user about if about is given" do
          valid_attributes[:current_password] = "my-secret"
          valid_attributes[:about] = "This is my about"
          put "/api/signup", xhr: true, params: { user: valid_attributes }, headers: valid_headers
          expect(user.reload.about).to eq valid_attributes[:about]
        end

        it "does not update user if current_password is missing" do
          put "/api/signup", xhr: true,
                             params: { user: valid_attributes }, headers: valid_headers
          expect(user.reload.name).to_not eq valid_attributes[:name]
        end
      end

      context "with invalid attributes" do
        it "does not update user details" do
          put "/api/signup", xhr: true, params: invalid_attributes, headers: valid_headers
          expect(user.reload.email).to_not eq invalid_attributes[:email]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    it "returns unauthorized for un-authenticated user" do
      put "/api/signup", xhr: true
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
