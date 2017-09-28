Refinery::Page.class_eval do

acts_as_indexed :fields => [:title, :body]

  def self.refinery_search_scope
    live
  end
end