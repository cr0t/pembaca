class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable
  
  references_many :uploads, :dependent => :delete
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource = nil)
    data = access_token.extra.raw_info
    if user = User.first(:conditions => { :email => data.email })
      user
    else # Create a user with a stub password.
      User.create!(
        :name         => data.name,
        :email        => data.email,
        :confirmed_at => Time.now,
        :facebook_id  => data.id,
        :password     => Devise.friendly_token[0, 20]
      )
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end
  
end
