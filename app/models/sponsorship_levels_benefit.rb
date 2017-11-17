class SponsorshipLevelsBenefit < ActiveRecord::Base
  belongs_to :sponsorship_level
  belongs_to :benefit
  belongs_to :code_type
end
