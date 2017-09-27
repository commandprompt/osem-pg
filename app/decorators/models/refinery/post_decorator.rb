Refinery::Blog::Post.class_eval do
  # Whitelist the :image_id parameter for form submission
  belongs_to :image, :class_name => '::Refinery::Image'
end