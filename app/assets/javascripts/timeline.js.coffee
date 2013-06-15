class TimeLine
  constructor: (@options) ->
    #all objects offset to top 
    @animateList = []
  
  displayYearRange: ()->
    app = this
    $("#rightBar > #year").empty()
    
    if not @yearList?
      $.ajaxSetup({async: false})
      $.get("/home/year_range",
        (data) ->
          console.log(data)
          app.yearList = data
      )
      $.ajaxSetup({async: true})
        
    len = @yearList.length
    @currentYear ||= @yearList[0]

    #add to right bar
    for year in @yearList
      elem = $("<div class='year'>" + year + "</div>")
      if year is @currentYear
        elem.attr("id", "current_year")
      elem.appendTo("#rightBar > #year")
      
  animate: (year) ->
    comment_top = $("#caption").offset().top
    app = this

    list = @animateList
    $.each @imgObjs, (obj) ->
      obj = this
      tag = $('<img class="animated_photo">')
      tag.css({
        top: 'auto',
        bottom: "-"+obj.bottom+"px",
        position: 'absolute',
        'margin-left': obj.margin_left+"px",
        width: obj.width
      })
      tag.appendTo("#leftBar")
      tag.attr('src', obj.src).load ->
        list.push(tag)
        tag
          .delay(100)
          .animate(
            {
              bottom: "1200px"
            },
            {
              step: ()->
                if (tag.offset().top <= comment_top && !(tag['displayed_comment']?))
                  tag['displayed_comment'] = true
                  app.displayCaption(obj.caption)
              queue: true,
              duration: 15000 + obj.bottom*20,
              complete: ()->
                idx = list.indexOf(tag)
                list.splice(idx, 1)
                tag.remove() #delete from DOM

                if (list.length == 0)
                  app.nextYear()
            }
          )
  
  displayCaption :(message)->
    $("div#caption").fadeOut()
    $("div#caption").html(message)
    $("div#caption").fadeIn('slow')

  nextYear: () ->
    curIdx = @yearList.indexOf(@currentYear)
    curIdx += 1
    if (curIdx >= @yearList.length)
      curIdx = 0

    @currentYear = @yearList[curIdx]
    this.displayYearRange()
    this.fetchNewImage(@currentYear, this.shuffleImage)
  

  fetchNewImage: (year, callback)->
    app = this
    $.get(
        "/home/photos/"+year,
        (data)->
          console.log(data)
          app.imgObjs = data
      )
      .done(
        ()->
          callback.apply(app)
          app.animate()
      )

  shuffleImage: () ->
    maxWidth = $("#leftBar").width()
    len = @imgObjs.length
    bottom = null

    $.each @imgObjs, (obj) ->
      obj = this
      left = Math.floor((Math.random()*(maxWidth - obj.width))+1)
      this["margin_left"] = left
      
      if bottom?
        bottom += 400
      else
        bottom = 0

      this["bottom"] = bottom

startClock = ()->
  today = new Date()
  h = today.getHours()
  m = today.getMinutes()
  s = today.getSeconds()
  
  m = checkTime(m)
  s = checkTime(s)

  $("div#clock").html(h+":"+m+":"+s)
  t = setTimeout(startClock ,500)

checkTime = (i)->
  i = "0" + i if i < 10
  i

$(document).ready ->
  startClock()
  app = new TimeLine({a:1, b:2},{a:1,b:2})
  app.displayYearRange()
  app.fetchNewImage(app.currentYear, app.shuffleImage)
