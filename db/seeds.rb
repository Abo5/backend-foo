# db/seeds.rb

puts "Starting to create user accounts..."

# Admin account
admin = User.create!(
  username: "SuperAdmin",
  email: "aszda33@gmail.com",
  password: "password!123321;wldkjnfbman[[Abood88%^&]]",
  password_confirmation: "password!123321;wldkjnfbman[[Abood88%^&]]",
  role: "admin",
  bio: "Super Admin Account",
  avatar_url: "https://example.com/admin_avatar.jpg"
)

# Monitor accounts
monitor1 = User.create!(
  username: "nora",
  email: "nora@nora.com",
  password: "password321##123",
  password_confirmation: "password321##123",
  role: "monitor",
  bio: "First Moderator Nora's Account",
  avatar_url: "https://example.com/monitor1_avatar.jpg"
)

monitor2 = User.create!(
  username: "Musallam",
  email: "abdullah.musallam@example.com",
  password: "PasswordForAbdullahMusallam123!",
  password_confirmation: "PasswordForAbdullahMusallam123!",
  role: "monitor",
  bio: "Moderator Abdullah Musallam",
  avatar_url: "https://example.com/monitor2_avatar.jpg"
)

monitor3 = User.create!(
  username: "Al-Wadai",
  email: "abdullah.waadey@example.com",
  password: "PasswordForAbdullahWaadey123!",
  password_confirmation: "PasswordForAbdullahWaadey123!",
  role: "monitor",
  bio: "Moderator Abdullah Waadey",
  avatar_url: "https://example.com/monitor3_avatar.jpg"
)

monitor4 = User.create!(
  username: "Mai",
  email: "mai@example.com",
  password: "PasswordForMai123!",
  password_confirmation: "PasswordForMai123!",
  role: "monitor",
  bio: "Moderator Mai",
  avatar_url: "https://example.com/monitor4_avatar.jpg"
)

monitor5 = User.create!(
  username: "Ziad",
  email: "ziad@example.com",
  password: "PasswordForZiad123!",
  password_confirmation: "PasswordForZiad123!",
  role: "monitor",
  bio: "Moderator Ziad",
  avatar_url: "https://example.com/monitor5_avatar.jpg"
)

monitor6 = User.create!(
  username: "Lama",
  email: "lama@example.com",
  password: "PasswordForLama123!",
  password_confirmation: "PasswordForLama123!",
  role: "monitor",
  bio: "Moderator Lama",
  avatar_url: "https://example.com/monitor6_avatar.jpg"
)

puts "User accounts created successfully!"
