Article.create(title: "Ferdinand Marcos")

Article.first.scrape!
Article.first.populate_cats!

Category.where(title: "1917_births").delete_all
Category.where(title: "1989_deaths").delete_all
Category.where(title: "Businesspeople_from_New_York_City").delete_all
Category.where(title: "Collars_of_the_Order_of_Isabella_the_Catholic").delete_all
Category.where(title: "Criminals_from_New_York_City").delete_all
Category.where(title: "Deaths_from_renal_failure").delete_all
Category.where(title: "Disease-related_deaths_in_Hawaii").delete_all
Category.where(title: "Converts_to_Roman_Catholicism_from_Catholic_Independent_denominations").delete_all
Category.where(title: "Knights_of_the_Order_of_the_Rajamitrabhorn").delete_all
Category.where(title: "Leaders_ousted_by_a_coup").delete_all
Category.where(title: "Military_personnel_from_New_York_City").delete_all
Category.where(title: "People_with_lupus").delete_all
Category.where(title: "Politicians_from_Honolulu").delete_all
Category.where(title: "Politicians_from_New_York_City").delete_all
Category.where(title: "Recipients_of_the_Order_of_the_Star_of_the_Romanian_Socialist_Republic").delete_all

Category.find_each(batch_size: 1) do |cat|
    cat.scrape_members!
end

Category.find_each(batch_size: 1) do |cat|
    cat.port_articles!
end

Article.find_each(batch_size: 1) do |a|
    a.populate_revs!
end

Revision.where(content: nil).find_each(batch_size: 100) do |a|
    t1 = Time.now
    a.scrape_content!
    print "\n" + (Time.now - t1).to_s + "\n"
end

=begin
Ferdinand_Marcos
Imelda_Marcos
20th-century_Filipino_lawyers
Chief_Commanders_of_the_Philippine_Legion_of_Honor
Filipino_anti-communists
Filipino_billionaires
Filipino_businesspeople
Filipino_criminals
Filipino_exiles
Filipino_expatriates_in_the_United_States
Filipino_lawyers
Filipino_military_personnel
Filipino_prisoners_of_war
Filipino_prisoners_sentenced_to_death
Filipino_Roman_Catholics
Ilocano_people
Kilusang_Bagong_Lipunan_politicians
Liberal_Party_(Philippines)_politicians
Marcos_family
Members_of_the_House_of_Representatives_of_the_Philippines_from_Ilocos_Norte
Nacionalista_Party_politicians
People_from_Ilocos_Norte
People_from_Manila
Philippine_Army_personnel
Philippine_presidential_candidates,_1965
Philippine_presidential_candidates,_1969
Philippine_presidential_candidates,_1981
Philippine_presidential_candidates,_1986
Philippines–United_States_relations
Presidents_of_the_Philippines
Presidents_of_the_Senate_of_the_Philippines
Prime_Ministers_of_the_Philippines
Secretaries_of_National_Defense_of_the_Philippines
Senators_of_the_5th_Congress_of_the_Philippines
University_of_the_Philippines_alumni
University_of_the_Philippines_College_of_Law_alumni
Presidents_of_the_Liberal_Party_of_the_Philippines
Burials_at_the_Heroes'_Cemetery
Recipients_of_the_Philippine_Medal_of_Valor
=end