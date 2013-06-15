module FBPhoto
  def get_timeline(access_token, year)
    from = Time.new(year, 01, 01).to_i
    to = Time.new(year+1, 01, 01).to_i
    api = Koala::Facebook::API.new(access_token)
    res = api.fql_query("SELECT pid, src_big, caption, like_info FROM photo WHERE
        pid IN (SELECT pid FROM photo_tag WHERE subject=me() AND created > #{from} AND created < #{to}) OR
        pid IN (select pid FROM photo WHERE owner=me() AND modified > #{from} AND created < #{to})
      ORDER BY modified LIMIT 100")
    @photos = []
    res.each do |r|
      width = 200 + 2*[r["like_info"]["like_count"]*5, 100].min
      @photos << {src: r["src_big"], caption: r["caption"], width: width}
    end
    @photos
  end
end