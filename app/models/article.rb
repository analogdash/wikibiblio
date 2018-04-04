class Article < ApplicationRecord
    serialize :categories, JSON
    serialize :links, JSON

    def scrape!
        uristring =
            "https://en.wikipedia.org/w/api.php?" +
            "action=parse" + "&" +
            "format=json" + "&" +
            "prop=title|categories|links" + "&"
        go = false
        if self.title != nil
            uristring += "page=#{self.title.gsub("+","%2B").gsub("&", "%26")}" #VERY IMPORTANT GSUB HACK. replaces symbols in URLs cause apparently URI.parse doesn't catch it
            go = true
        elsif self.pageid != nil
            uristring += "pageid=#{self.pageid.to_s}"
            go = true
        end
        if go
            begin #this is necessary for some weird shit with unicode
                uri = URI.parse(uristring)
            rescue URI::InvalidURIError
                uri = URI.parse(URI.escape(uristring))
            end
            wikiapidata = Net::HTTP.get_response(uri)
            wikijsondata = JSON.parse(wikiapidata.body) #INSERT SOMETHING HERE ABOUT CATCHING ERRORS
            self.title = wikijsondata["parse"]["title"] #string
            self.pageid = wikijsondata["parse"]["pageid"] #string
            self.categories = wikijsondata["parse"]["categories"] #array of hashes
            self.links = wikijsondata["parse"]["links"] #array of hashes
            self.save
        end
    end
    
    def populate_friends!
        self.links.each do |link|
            unless link["*"].start_with?("Wikipedia:", "Template:", "Template talk:", "Portal:", "Help:", "Category:")
                if link["exists"]
                    unless Article.where(title: link["*"]).exists?
                        a = Article.new
                        a.title = link["*"]
                        a.save
                    end
                end
            end
        end
    end
    
    
end

# first scrape 1
# friends 673
# friends of friends (78,538)
# friends of friends 450000~
#total 5,597,814

#ARTICLES WITHOUT PAGEIDS HAVE NOT YET BEEN SCRAPED
#Article.where(pageid: nil).each do |a|
#a.scrape!
#end

#Article.where(pageid: nil)

