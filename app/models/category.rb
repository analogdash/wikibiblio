class Category < ApplicationRecord
    serialize :articles, JSON
    
    def scrape_members!
        uristring =
            "https://en.wikipedia.org/w/api.php?" +
            "format=json" + "&" +
            "action=query" + "&" +
            "list=categorymembers" + "&" +
            "cmlimit=500" + "&" +
            "cmprop=ids|title|type" + "&"
        uristring += "cmtitle=Category:#{self.title.gsub("+","%2B").gsub("&", "%26")}" #VERY IMPORTANT GSUB HACK. replaces symbols in URLs cause apparently URI.parse doesn't catch it
        
        begin #this is necessary for some weird shit with unicode
            uri = URI.parse(uristring)
        rescue URI::InvalidURIError
            uri = URI.parse(URI.escape(uristring))
        end
        
        wikiapidata = Net::HTTP.get_response(uri)
        #INSERT SOMETHING HERE ABOUT CATCHING ERRORS
        #INSERT SOMETHING HERE ABOUT CATCHING NO NET ERRORS
        #INSERT SOMETHING HERE ABOUT CATCHING INVALID API CALL ERRORS
        #INSERT SOMETHING HERE ABOUT CATCHING ERRORS

        wikijsondata = JSON.parse(wikiapidata.body) 
        
        self.articles = wikijsondata["query"]["categorymembers"]
        
        while wikijsondata.keys.include?("continue") do
            conti = wikijsondata["continue"]["continue"]
            cmconti = wikijsondata["continue"]["cmcontinue"]
            uristring2 = uristring + "&continue=" + conti + "&cmcontinue=" + cmconti
            begin #this is necessary for some weird shit with unicode
                uri = URI.parse(uristring2)
            rescue URI::InvalidURIError
                uri = URI.parse(URI.escape(uristring2))
            end
            wikiapidata = Net::HTTP.get_response(uri)
            wikijsondata = JSON.parse(wikiapidata.body)
            self.articles.concat wikijsondata["query"]["categorymembers"]
        end
        
        self.save
    end
    
    def port_articles!
        self.articles.each do |art|
            if art["type"] == "page"
                unless Article.where(title: art["title"]).exists?
                    newArt = Article.new
                    newArt.title = art["title"]
                    newArt.pageid = art["pageid"]
                    newArt.save
                    #newArt.scrape!
                end
            end
        end
    end #Category.find_each(batch_size: 1) {|a| a.port_articles!}
    
end

#Category.find_each(batch_size: 1) {|a| a.scrape_members!}

