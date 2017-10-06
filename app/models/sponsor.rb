class Sponsor < ActiveRecord::Base
  rolify

  belongs_to :conference

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates_presence_of :name, :website_url

  def self.ordered
    sponsors = Sponsor.order(:name)
    sponsors
  end

end
