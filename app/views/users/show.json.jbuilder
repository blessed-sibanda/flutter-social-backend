json.partial! "users/user", user: @user
json.email @user.email

json.followers @user.followers, partial: "users/user", as: :user
json.following @user.following, partial: "users/user", as: :user
