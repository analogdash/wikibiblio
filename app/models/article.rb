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
                        Article.create(title: link["*"])
                    end
                end
            end
        end
    end
    
    def populate_cats!
        self.categories.each do |cat|
            unless cat["hidden"]
                unless Category.where(title: cat["*"]).exists?
                    Category.create(title: cat["*"])
                end
            end
        end
    end
    
    def populate_revwikitxt!
        uristring =
            "https://en.wikipedia.org/w/api.php?" +
            "action=query" + "&" +
            "format=json" + "&" +
            "prop=revisions" + "&" +
            "rvlimit=max" + "&" +
            "rvprop=ids|content" + "&" +
            "pageids=#{self.pageid.to_s}"
        uri = URI(uristring)
        wikiapidata = Net::HTTP.get_response(uri)
        wikijsondata = JSON.parse(wikiapidata.body)
        wikijsondata["query"]["pages"][self.pageid.to_s]["revisions"].each do |revision|
            r = Revision.where(revid: revision["revid"]).take
            if r
                r.update(wikitext: revision["*"])
            end
        end
        
        while ! wikijsondata.keys.include?("batchcomplete") do
            conti = wikijsondata["continue"]["continue"]
            rvconti = wikijsondata["continue"]["rvcontinue"]
            uristring2 = uristring + "&continue=" + conti + "&rvcontinue=" + rvconti
            uri = URI(uristring2)
            wikiapidata = Net::HTTP.get_response(uri)
            wikijsondata = JSON.parse(wikiapidata.body)
            wikijsondata["query"]["pages"][self.pageid.to_s]["revisions"].each do |revision|
                r = Revision.where(revid: revision["revid"]).take
                if r
                    r.update(wikitext: revision["*"])
                end
            end
        end
    end
    
    def populate_revs!
        uristring =
            "https://en.wikipedia.org/w/api.php?" +
            "action=query" + "&" +
            "format=json" + "&" +
            "prop=revisions" + "&" +
            "rvlimit=max" + "&" +
            "rvprop=ids|timestamp|user|userid|comment|size|content" + "&" +
            "pageids=#{self.pageid.to_s}"
        uri = URI(uristring)
        wikiapidata = Net::HTTP.get_response(uri)
        wikijsondata = JSON.parse(wikiapidata.body)
        #breakme = false
        wikijsondata["query"]["pages"][self.pageid.to_s]["revisions"].each do |revision|
            #if Revision.where(revid: revision["revid"]).exists? == false
                rev = Revision.new
                rev.pageid = self.pageid
                rev.revid = revision["revid"]
                rev.parentid = revision["parentid"]
                rev.comment = revision["comment"]
                rev.user = revision["user"]
                rev.userid = revision["userid"]
                rev.size = revision["size"]
                rev.timestamp = DateTime.parse(revision["timestamp"])
                rev.wikitext = revision["*"]
                rev.save
            #else
            #    breakme = true
            #    break
            #end
        end
            
        #if breakme == false
            while ! wikijsondata.keys.include?("batchcomplete") do
                conti = wikijsondata["continue"]["continue"]
                rvconti = wikijsondata["continue"]["rvcontinue"]
                uristring2 = uristring + "&continue=" + conti + "&rvcontinue=" + rvconti
                uri = URI(uristring2)
                wikiapidata = Net::HTTP.get_response(uri)
                wikijsondata = JSON.parse(wikiapidata.body)
                wikijsondata["query"]["pages"][self.pageid.to_s]["revisions"].each do |revision|
                    #if Revision.where(revid: revision["revid"]).exists? == false
                        rev = Revision.new
                        rev.pageid = self.pageid
                        rev.revid = revision["revid"]
                        rev.parentid = revision["parentid"]
                        rev.comment = revision["comment"]
                        rev.user = revision["user"]
                        rev.userid = revision["userid"]
                        rev.size = revision["size"]
                        rev.timestamp = DateTime.parse(revision["timestamp"])
                        rev.wikitext = revision["*"]
                        rev.save
                    #else
                    #    breakme = true
                    #    break
                    #end
                end
                #if breakme == true
                #    break 
                #end
            end
        #end    
    end
    
    
    def integritous?
        revis = Revision.where(pageid: self.pageid).order("timestamp")
        r = revis.first
        expected = revis.count
        sum = 1
        while true
            if r1 = revis.where(parentid: r.revid).take
                if r.revid >= r1.revid
                    puts r.revid.to_s + " vs " + r1.revid.to_s + " and " + sum.to_s + " out of " + expected.to_s
                    break
                end
                sum += 1
                r = r1
                puts r.revid.to_s + " and " + sum.to_s + " out of " + expected.to_s
            else
                puts "OH NO"
                break
            end
        end
        if sum == revis.count
            return true
        else
            return false
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


=begin
# For grabbing parsetrees and texts
uristring =
    "https://en.wikipedia.org/w/api.php?" +
    "action=parse" + "&" +
    "format=json" + "&" +
    "prop=parsetree" + "&" +
    "pageid=#{a.pageid.to_s}"
begin #this is necessary for some weird shit with unicode
    uri = URI.parse(uristring)
rescue URI::InvalidURIError
    uri = URI.parse(URI.escape(uristring))
end
wikiapidata = Net::HTTP.get_response(uri)
wikijsondata = JSON.parse(wikiapidata.body)
parsetree = Nokogiri::XML(wikijsondata["parse"]["parsetree"]["*"])



#code to update Revisions and parse them too.
def save_revision_info (article,revision)
  rev = Revision.new
  rev.pageid = article.pageid
  rev.revid = revision["revid"]
  rev.parentid = revision["parentid"]
  rev.comment = revision["comment"]
  rev.user = revision["user"]
  rev.userid = revision["userid"]
  rev.size = revision["size"]
  rev.instances_count = 0
  rev.instances_normal_count = 0
  rev.instances_broken_count = 0
  rev.timestamp = DateTime.parse(revision["timestamp"])

  unless revision["*"] == nil
    mwtext = revision["*"]
    refindex = 0
    refendex = 0
    position = 1
    while true do
      refindex = mwtext.index("<ref", refendex)
      if refindex == nil
        break
      end
      nextbrack = mwtext.index(/<[^!]/, refindex + 1)
      nextbrack = !nextbrack ? -1 : nextbrack #Convert nils to -1
      slashref = mwtext.index("/>", refindex)
      slashref = !slashref ? -1 : slashref
      refendex = mwtext.index("</ref>",refindex)
      refendex = !refendex ? -1 : refendex

      if ((nextbrack < slashref) || (slashref == -1)) && (nextbrack != -1)
        if nextbrack == refendex
          reftype = 'normal'
          refendex += 6
          rev.instances_normal_count += 1
        else
          reftype = 'broken'
          refendex = nextbrack
          rev.instances_broken_count += 1
        end
      elsif ((slashref < nextbrack) || (nextbrack == -1)) && ((slashref < refendex) || (refendex == -1)) && (slashref != -1)
        #NOTE THAT THIS is also triggered by <references/> make sure to catch it.
        reftype = 'short'
        refendex = slashref + 2
        next #we're skipping short references for now
      end

      refstring = ReferenceInstance.new
      refstring.revid = rev.revid
      refstring.reftype = reftype
      refstring.wikitext = mwtext[refindex,refendex-refindex]
      refstring.size = refendex-refindex
      refstring.position = position

      doc = Nokogiri::HTML(refstring.wikitext)
      tag = doc.css("ref")[0]
      unless tag == nil
        refstring.refname = tag["name"]
        refstring.content = tag.content
        refstring.comments = ""
        tag.children.each do |n|
          if n.comment?
            unless refstring.comments == ""
              refstring.comments += ","
            end
            refstring.comments += n.content
          end
        end
      end
      position += 1
      refstring.save
    end
  end
  rev.instances_count = rev.instances_normal_count + rev.instances_broken_count
  rev.save
end


=end