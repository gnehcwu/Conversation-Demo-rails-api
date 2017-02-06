class User < ActiveRecord::Base
  has_many :conversations, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_save   :downcase_email
  before_create :generate_authentication_token

  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }
  has_secure_password

  validates :password, length: { minimum: 2 }, allow_blank: true

  validates :password_confirmation, :presence => true, :if => '!password.nil?'

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    def generate_authentication_token
      loop do
        self.authentication_token = SecureRandom.base64(64)
        break unless User.find_by(authentication_token: authentication_token)
    end
    end

end
