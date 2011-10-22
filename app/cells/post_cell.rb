class PostCell < Cell::Rails
  cache :related do |cell, post|
    post.model_cache_key
  end

  def related(post)
    @related_posts = post.related_posts
    render
  end

end
