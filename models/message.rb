class Message < ActiveRecord::Base
  has_secure_password

  validates :body, presence: true
  validates :destroy_time, :visit_limit, numericality: { greater_than_or_equal_to: 1 }

  before_create :create_token, :encrypt_body
  after_create do
    DestroyMessageWorker.perform_at(self.destroy_time.hours.from_now, self.id)
  end

  def view_limit?
    visit_number == visit_limit ? true : false
  end

  private

  def create_token
    self.token = SecureRandom.urlsafe_base64
  end

  def encrypt_body
    self.body = Encryptor.new(self.body, self.password_digest).encrypt
  end
end
