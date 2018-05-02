class Revision < ApplicationRecord
    def scrape_content!
        uristring =
            "https://en.wikipedia.org/w/api.php?" +
            "action=parse" + "&" +
            "format=json" + "&" +
            "prop=text|wikitext|parsetree" + "&" +
            "oldid=" + self.revid.to_s
        uri = URI.parse(uristring)
        wikiapidata = Net::HTTP.get_response(uri)
        wikijsondata = JSON.parse(wikiapidata.body)
        if wikijsondata.keys.include?("error")
            self.content = ""
            self.parsetree = ""
        else
            self.content = wikijsondata["parse"]["text"]["*"]
            self.parsetree = wikijsondata["parse"]["parsetree"]["*"] #string
        end
        self.save
    end
    
    def reparse!
        self.parsetree = eval(self.parsetree)["*"]
        self.content = evale(self.content)["*"]
        self.save
    end
    
    def extract_refs!
        mwtext = self.wikitext
        parsetree = self.parsetree
        content = self.content
        
        refindex = 0
        refendex = 0
        position = -1
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
                    #rev.instances_normal_count += 1
                else
                    reftype = 'broken'
                    refendex = nextbrack
                    #rev.instances_broken_count += 1
                end
            elsif ((slashref < nextbrack) || (nextbrack == -1)) && ((slashref < refendex) || (refendex == -1)) && (slashref != -1)
                #NOTE THAT THIS is also triggered by <references/> make sure to catch it.
                reftype = 'short'
                refendex = slashref + 2
                next #we're skipping short references for now
            end

            reftext = mwtext[refindex,refendex-refindex] #THIS IS THE REFERENCE IN WIKITEXT FORM FROM <REF> TO </REF>

            doc = Nokogiri::HTML(reftext)
            tag = doc.css("ref")[0]
            unless tag == nil
                refname = tag["name"] #THE ""NAME"" OF THE REFERENCE
                refcontent = tag.content # THE ""CONTENT"" OF THE REFERENCE
                #
                #NO COMMENTS FOR NOW
                #
                #comments = ""  
                #tag.children.each do |n|
                #    if n.comment?
                #        unless comments == ""
                #            comments += ","
                #        end
                #        comments += n.content
                #    end
                #end
            end
            
            position += 1
            
            refstring = ReferenceInstance.new
            refstring.revid = self.revid
            refstring.reftype = reftype
            refstring.wikitext = wikitext
            refstring.size = refendex-refindex
            refstring.position = position
            refstring.refname = refname
            refstring.content = refcontent
            refstring.comments = comment
            refstring.save
            
        end
        self.scraped = true
        self.save
    end
end
