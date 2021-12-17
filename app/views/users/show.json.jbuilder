json.cache! [@user] do
  json.partial! "users/user", user: @user, cached: true
  json.email @user.email
  json.unconfirmed_email @user.unconfirmed_email
  json.about @user.about
end
