class UserDecorator < Draper::Decorator

  delegate_all

  def first_name
  	user.name.split(' ')[0] rescue ''
  end

  def last_name
  	user.name.split(' ')[1] rescue ''
  end

end