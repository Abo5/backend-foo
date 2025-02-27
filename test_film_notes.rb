require 'rest-client'

url = 'http://localhost:3000/movies'
payload = {
  "movie[title]"              => "Test Movie",
  "movie[runtime]"            => "02:00:00",
  "movie[overview]"           => "هذا فيلم تجريبي",
  "movie[production_company]" => "شركة الإنتاج التجريبية",
  "movie[release_date]"       => "2025-02-23",
  "movie[director]"           => "المخرج التجريبي",
  "movie[cast]"               => "ممثل 1, ممثل 2",
  "movie[trailer_url]"        => "http://example.com/trailer",
  "movie[imdb_age_rating]"    => "PG-13",
  "movie[poster_file]"        => File.new('/Users/qppn/Desktop/IMG_9758.jpg', 'rb')
}

headers = {
  "Authorization" => "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1Iiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzQwMzMxNjY1LCJleHAiOjE3NDAzMzg4NjUsImp0aSI6ImVlMGVjZTZkLTdkNTYtNGE4My05OTU0LWNiMjA3YTVjNGI1NCJ9.0bw93hQaF_AQGV84-07pjbKbd5KFEXltm5eZF19wyjQ",
  "Cookie"      => "user_id=eyJfcmFpbHMiOnsibWVzc2FnZSI6Ik5RPT0iLCJleHAiOiIyMDI1LTAyLTIzVDE5OjI3OjQ1LjA1M1oiLCJwdXIiOiJjb29raWUudXNlcl9pZCJ9fQ%3D%3D--d98280322e36e27d3f4fa376d841e0c805f741ad"
}

response = RestClient.post(url, payload, headers)
puts response.body
