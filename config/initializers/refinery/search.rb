Refinery::Search.configure do |config|
  config.enable_for = ["Refinery::Page", "Refinery::Blog::Post", "Refinery::News::Item"]
  # config.page_url = "/search"
  # config.results_per_page = 10
end