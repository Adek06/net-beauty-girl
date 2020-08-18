class GirlPhotoPost < ApplicationRecord
  validates :url, uniqueness: true
end
