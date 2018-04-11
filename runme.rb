Article.find_each(batch_size: 1) do |a|
    a.populate_revs!
end