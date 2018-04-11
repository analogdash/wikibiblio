class Revision < ApplicationRecord
    def scrape_content!
        uristring =
            "https://en.wikipedia.org/w/api.php?" +
            "action=parse" + "&" +
            "format=json" + "&" +
            "prop=text|parsetree" + "&" +
            "oldid=" + self.revid.to_s
        uri = URI.parse(uristring)
        wikiapidata = Net::HTTP.get_response(uri)
        wikijsondata = JSON.parse(wikiapidata.body)
        if wikijsondata.keys.include?("error")
            self.content = ""
            self.parsetree = ""
        else
            self.content = wikijsondata["parse"]["text"]
            self.parsetree = wikijsondata["parse"]["parsetree"] #string
        end
        self.save
    end
end
