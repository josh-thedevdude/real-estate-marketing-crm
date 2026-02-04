class ContactImportLog < ApplicationRecord
  acts_as_tenant :organization
  
  belongs_to :organization
  belongs_to :user
  
  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }
  
  validates :filename, presence: true
  validates :job_id, presence: true, uniqueness: true
  
  # Generate unique job ID before creation
  before_validation :generate_job_id, on: :create
  
  def success_rate
    return 0 if total_rows.zero?
    (successful_rows.to_f / total_rows * 100).round(2)
  end
  
  private
  
  def generate_job_id
    self.job_id ||= SecureRandom.uuid
  end
end
