class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :oauthable
  
  references_many :uploads, :dependent => :delete
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
      # Get the user email info from Facebook for sign up
      data = ActiveSupport::JSON.decode(access_token.get('/me'))

      if user = User.first(:conditions => { :email => data["email"] })
        user
      else
        # Create an user with a stub password.
        User.create!(
          :name         => data["name"],
          :email        => data["email"],
          :confirmed_at => Time.now,
          :facebook_id  => data["id"],
          :password     => Devise.friendly_token)
      end
    end
end
