class Sponsorship < ActiveRecord::Base
  belongs_to :sponsorship_level
  belongs_to :conference
  belongs_to :sponsor

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  delegate :name, to: :sponsor
  delegate :description, to: :sponsor
  delegate :website_url, to: :sponsor
  delegate :logo_file_name, to: :sponsor
  delegate :picture, to: :sponsor
end
