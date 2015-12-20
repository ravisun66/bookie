class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
      user ||= User.new # guest user (not logged in)
      can :read, :all
      can :manage, Book do |book|
        book.try(:user) == user
      end
  
  end
end