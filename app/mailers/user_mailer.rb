class UserMailer < ActionMailer::Base
  default from: "Followr <no-reply@followr.club>"

  def reauthentication_notification(user)
    @name = user.name || user.twitter_username
    mail(:to => user.read_attribute(:email), :subject => "You need to reauthenticate yourself").deliver if user.email
  end
end