task :send_reminders => :environment do
  GirlPhotoPost.find_by_isPush false
end