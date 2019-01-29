goog.provide "status.main"

window.Status or= {}

class window.Status.Widget
  _version = "3.8.0"

  constructor: (@options = {}) ->
    requiredOptions = ["hostname", "selector"]
    optionsMissing = !@options?
    optionsMissing = !(o of @options) for o in requiredOptions

    if @options == {} || optionsMissing
      warn "Options missing or invalid"
      return

    defaultOptions = {
      "ssl": true,
      "css": true,
      "debug": false,
      "outOfOffice": false,
      "linkTarget": "_blank",
      "display": {
        "hideOnError": true,
        "pane": true,
        "paneStatistics": true,
        "ledOnly": false,
        "panePosition": "bottom-right",
        "ledPosition": "left",
        "statistic": {
          "uptimeDecimals": 4,
          "minIncidentFreeStreak": 86400
        },
        "outOfOffice": {
          "resetStatusLed": false
        }
      }
      "i18n": {
        "heading": "Issues",
        "toggle": "${state}",
        "loading": "Loading status...",
        "error": "Connection error",
        "statistic": {
          "streak": "No events for ${duration}!"
          "uptime": "${percent}% Uptime"
        },
        "issue": {
          "scheduled": "Scheduled",
          "empty": {
            "operational": "There are currently no reported issues."
            "degraded": "There are currently no reported issues,
              but we have detected that at least one component is degraded."
            "outage": "There are currently no reported issues,
              but we have detected outages on at least one component."
          }
        },
        "state": {
          "outOfOffice": "Out of Office"
        },
        "linkBack": "View Status Page",
        "time": {
          "distanceInWords": {
            "halfAMinute": "half a minute",
            "lessThanXSeconds": {
              "one": "less than 1 second",
              "other": "less than ${count} seconds"
            },
            "xSeconds": {
              "one": "1 second",
              "other": "${count} seconds"
            },
            "lessThanXMinutes": {
              "one": "less than a minute",
              "other": "less than ${count} minutes"
            },
            "xMinutes": {
              "one": "1 minute",
              "other": "${count} minutes"
            },
            "aboutXHours": {
              "one": "about 1 hour",
              "other": "about ${count} hours"
            },
            "xDays": {
              "one": "1 day",
              "other": "${count} days"
            },
            "aboutXMonths": {
              "one": "about 1 month",
              "other": "about ${count} months"
            },
            "xMonths": {
              "one": "1 month",
              "other": "${count} months"
            },
            "aboutXYears": {
              "one": "about 1 year",
              "other": "about ${count} years"
            },
            "overXYears": {
              "one": "over 1 year",
              "other": "over ${count} years"
            },
            "almostXYears": {
              "one": "almost 1 year",
              "other": "almost ${count} years"
            }
          }
        }
      }
    }

    @options = deepMerge defaultOptions, @options
    @debug = @options["debug"]
    @hostname = @options["hostname"]
    @display = @options["display"]
    @i18n = @options["i18n"]
    @outOfOffice = @display["outOfOffice"]

    if !/^https?:\/\//i.test(@hostname)
      protocol = (if @options["ssl"] then "https" else "http")
      @hostname = "#{protocol}://#{@hostname}"

    @issues = {}
    @visibleIssues = []

    @ready => @attachWidget()

  ready: (fn) ->
    return fn() if document.readyState != "loading"
    document.addEventListener "DOMContentLoaded", fn

  injectStyles: ->
    link = document.createElement "link"
    link.rel = "stylesheet"
    link.href = "https://libraries.hund.io/status-js/status-#{_version}.css"
    document.head.appendChild link

  attachWidget: ->
    @elements = {}

    widgetSelector = @options["selector"]
    @elements.widget = document.querySelector widgetSelector

    if @elements.widget == null
      warn "Unable to find element with selector: #{widgetSelector}"
      return

    @setVisibility "hidden"
    @injectStyles() if @options["css"]
    @connect()

    addClass @elements.widget, "status-widget"

    @elements.led = @createEl "span", @elements.widget, "led"

    unless @display["ledOnly"]
      @elements.state = @createEl "span", @elements.widget, "state"
      setElText @elements.state, @i18n["loading"]

    @officeHoursTimeout()

    if @display["ledPosition"] != "left"
      @elements.widget.appendChild @elements.led

    @elements.pane = @createEl "div", @elements.widget, "pane"
    setElDataAttr @elements.pane, "open", false
    setElDataAttr @elements.pane, "position", @display["panePosition"]

    @elements.paneHeader = @createEl "div", @elements.pane, "pane__header"
    @elements.paneHeading = @createEl "strong", @elements.paneHeader, "pane__heading"
    setElText @elements.paneHeading, @i18n["heading"]

    if @display["paneStatistics"]
      @elements.paneStatistics = @createEl "div", @elements.paneHeader, "pane_statistics"
      @elements.statisticUptime = @buildStatistic()
      @elements.statisticStreak = @buildStatistic()

    @elements.paneContainer = @createEl "div", @elements.pane, "pane__container"
    @elements.paneText = @createEl "span", @elements.paneContainer, "pane__text"
    setElText @elements.paneText, @i18n["loading"]

    @elements.paneFooter = @createEl "a", @elements.pane, "pane__footer"
    @buildLink @elements.paneFooter, @hostname
    setElText @elements.paneFooter, @i18n["linkBack"]

    if @display["pane"]
      addClass @elements.widget, "status-widget--pane-enabled"

      window.addEventListener "resize", @debounce(@alignPane, 250)

      @elements.widget.addEventListener "click", (e) =>
        e.preventDefault()
        e.stopPropagation()
        state = (@elements.pane.dataset.open == "false")
        setElDataAttr @elements.pane, "open", state
      , false

      @elements.pane.addEventListener "click", (e) -> e.stopPropagation()

      document.addEventListener "click", (e) =>
        if @elements.pane.dataset.open
          setElDataAttr @elements.pane, "open", false
      , false

  setVisibility: (visibility) ->
    @elements.widget.style.visibility = visibility

  connect: ->
    if !!window["EventSource"]
      url = "#{@hostname}/live/v2/"
      if @options["component"]?
        url += "component/#{@options["component"]}"
      else
        url += "status_page"

      @source = new window["EventSource"](url)

      @source.onerror = @errorListener
      @source.onopen = @openListener

      @addEventListeners()
    else
      log "Browser unsupported"

  reconnect: (backoff = 0) ->
    clearTimeout @reconnectTimer
    @reconnectTimer = setTimeout =>
      @source.close()
      @connect()
    , backoff

  errorListener: =>
    @reconnectAttempt = 0 unless @reconnectAttempt > 0
    delay = backoff(@reconnectAttempt)
    log "Reconnecting in #{delay}ms" if @debug
    @reconnect delay
    @reconnectAttempt += 1

    setElDataAttr @elements.led, "state", "pending"

    unless @display["hideOnError"]
      @setVisibility "visible"
      stateText = if delay > 10000 then @i18n["error"] else @i18n["loading"]
      setElText @elements.state, stateText if @elements.state

  openListener: =>
    @reconnectAttempt = 0
    log "Connected"
    @setVisibility "visible"

  addEventListeners: ->
    eventListeners = {
      "init_event": @initListener,
      "status_created": @basicEventListener,
      "degraded": @basicEventListener,
      "restored": @basicEventListener,
      "issue_created": @issueCreatedListener,
      "issue_updated": @issueUpdatedListener,
      "issue_resolved": @issueResolvedListener,
      "issue_reopened": @issueReopenedListener,
      "issue_cancelled": @issueResolvedListener,
      "issue_started": @issueCreatedListener,
      "issue_ended": @issueResolvedListener,
      "cache_grown": @basicEventListener,
      "cache_rebuilt": @basicEventListener
    }

    for event, listener of eventListeners
      @source.addEventListener event, listener, false

  basicEventListener: (e) =>
    @parseBasicEventData e

  initListener: (e) =>
    data = @parseBasicEventData e

    if "issues" of data
      @issues = {}
      @visibleIssues = []

      for issue in data["issues"]
        @insertIssue issue

    @updateIssues()

  issueCreatedListener: (e) =>
    data = @parseBasicEventData e

    if "issue" of data
      data["issue"]["updates"] = []
      @insertIssue data["issue"]

    @updateIssues()

  issueUpdatedListener: (e) =>
    data = @parseBasicEventData e

    if "update" of data
      issueId = data["update"]["issue_id"]
      return unless issueId of @issues

      @issues[issueId]["updates"].unshift data["update"]
      @updateIssues()

  issueResolvedListener: (e) =>
    data = @parseBasicEventData e

    issueId = ""
    if "update" of data
      issueId = data["update"]["issue_id"]
    else if "issue" of data
      issueId = data["issue"]["id"]

    return unless issueId of @issues
    @removeIssue issueId
    @updateIssues()

  issueReopenedListener: (e) =>
    data = @parseBasicEventData e

    if "update" of data
      @insertIssue data["update"]["issue"]

    @updateIssues()

  parse: (event) ->
    try
      return JSON.parse(event.data) if "data" of event
    catch e
      warn "Received invalid event payload"
    {}

  parseBasicEventData: (e) ->
    data = @parse e
    @humanData = {
      state: @humanState(data.state),
      percentUptime: @humanPercentUptime(data.percent_uptime),
      incidentFreeStreak: @humanIncidentFreeStreak(data.incident_free_streak)
    }

    @updateState data.state
    @updatePercentUptime data.percent_uptime, @humanData.percentUptime
    @updateIncidentFreeStreak data.incident_free_streak,
      @humanData.incidentFreeStreak
    @updateToggle @humanData
    data

  updateState: (state) ->
    state = "pending" if !state?

    if @isOutOfOffice() && @outOfOffice["resetStatusLed"]
      setElDataAttr @elements.led, "state", "pending"
    else
      setElDataAttr @elements.led, "state", state

    @state = state
    @updateIssuePaneText()

  updateToggle: (humanData) ->
    return unless @elements.state?
    text = template @i18n["toggle"], humanData
    @stateText = text

    if @isOutOfOffice()
      fakeHumanData = Object.assign {}, humanData
      fakeHumanData.state = @humanState "outOfOffice"
      text = template @i18n["toggle"], fakeHumanData

    setElText @elements.state, text
    @alignPane()

  updatePercentUptime: (uptime, humanUptime) ->
    return unless @elements.statisticUptime
    setElText @elements.statisticUptime, humanUptime

  updateIncidentFreeStreak: (streak, humanStreak) ->
    return unless @elements.statisticStreak
    toggle = @incidentFreeStreakLessThanMin streak
    @toggleStatistic @elements.statisticStreak, toggle
    setElText @elements.statisticStreak, humanStreak

  updateIssues: ->
    if @elements.paneIssues?
      @elements.paneContainer.removeChild @elements.paneIssues
    @elements.paneIssues = @createEl "div",
      @elements.paneContainer, "pane__issues"

    unless @issuesPresent()
      @updateIssuePaneText()
      return

    setElDataAttr @elements.paneText, "hidden", true

    for issueId in @visibleIssues
      continue unless issueId of @issues
      @createIssue @issues[issueId]

  updateIssuePaneText: ->
    return if @issuesPresent()
    setElText @elements.paneText, @i18n["issue"]["empty"][@state]

  humanState: (state) ->
    state = "pending" if !state?
    text = state
    if "state" of @i18n
      text = @i18n["state"][state] if state of @i18n["state"]
    text

  humanPercentUptime: (uptime) ->
    uptimeDecimals = clamp @display["statistic"]["uptimeDecimals"], 0, 10
    percent = +parseFloat(uptime).toFixed uptimeDecimals
    template @i18n["statistic"]["uptime"], percent: percent

  humanIncidentFreeStreak: (streak) ->
    return "" if @incidentFreeStreakLessThanMin streak
    fromTime = (new Date // 1000) - streak
    template @i18n["statistic"]["streak"], duration: @distanceInWords(fromTime)

  insertIssue: (issue) ->
    id = issue["id"]
    @issues[id] = issue
    return if id in @visibleIssues
    @visibleIssues.splice @issuePosition(id), 0, id

  removeIssue: (id) ->
    delete @issues[id]
    return unless id in @visibleIssues
    @visibleIssues.splice @visibleIssues.indexOf(id), 1

  createIssue: (issue) ->
    container = @createEl "div", @elements.paneIssues, "issue"

    data = @issueData(issue)

    issueElements = {
      "components": {
        "el": "strong",
        "text": issue["components"].map((c) -> c["name"]).join ", "
      },
      "title": { "el": "a", "text": issue["title"] + ": " },
      "body": { "el": "p", "html": data.body },
      "label": { "el": "span", "text": data.label },
      "time": { "el": "span", "text": data.date }
    }

    for k, v of issueElements
      issueElements[k] = @createEl v["el"], container, "issue__#{k}"
      if "html" of v
        setElHTML issueElements[k], v["html"]
      else
        setElText issueElements[k], v["text"]

    @buildLink issueElements["title"], "#{@hostname}/issues/#{issue["id"]}"

  issueData: (issue) ->
    standing = !!issue["standing"]
    scheduled = !!issue["scheduled"]
    updates = issue["updates"].length > 0

    if scheduled
      label = @i18n["issue"]["scheduled"] unless standing
      date = issue["starts_at"]

    issue = issue["updates"][0] if updates

    body = issue["body"]
    label = issue["label"] if standing
    date = issue["created_at"] unless scheduled

    date = new Date(date * 1000)
    if toLocaleStringSupportsLocales() && "dates" of @i18n
      dateOptions = @i18n["dates"]
      date = date.toLocaleString dateOptions["locale"], dateOptions["options"]
    else
      date = date.toLocaleString()

    { body: body, label: label, date: date }

  issuePosition: (id) ->
    now = Math.floor(Date.now() / 1000)
    timestamps = "past": [], "future": []
    issueTimestamp = 0

    for _, issue of @issues
      scheduled = !!issue["scheduled"]
      timestamp = if scheduled then issue["starts_at"] else issue["created_at"]
      timestamps[if timestamp > now then "future" else "past"].push timestamp
      issueTimestamp = timestamp if issue["id"] == id

    if issueTimestamp in timestamps["future"]
      timestamps["future"].sort().indexOf(issueTimestamp) +
        timestamps["past"].length
    else
      timestamps["past"].sort().reverse().indexOf(issueTimestamp)

  issuesPresent: ->
    Object.keys(@issues).length != 0

  incidentFreeStreakLessThanMin: (streak) ->
    streakMin = Math.max 0, @display["statistic"]["minIncidentFreeStreak"]
    streak < streakMin

  createEl: (type, parent, className = undefined) ->
    cssClass = "status-widget"
    cssClass += "__#{className}" if className?
    createEl type, cssClass, parent

  buildLink: (el, href) ->
    el.href = href
    el.target = @options["linkTarget"]
    el.rel = "noopener"
    el

  buildStatistic: ->
    @createEl "span", @elements.paneStatistics, "pane_statistic"

  toggleStatistic: (statistic, toggle) ->
    setElDataAttr statistic, "hidden", toggle

  alignPane: ->
    offset = @elements.led.offsetLeft

    if endsWith @display["panePosition"], "left"
      offset -= @elements.pane.offsetWidth
      offset += 20 + @elements.led.offsetWidth
    else
      offset -= 20

    @elements.pane.style.left = offset + "px"

  resetState: ->
    return unless @state? && @humanData?
    @updateState @state
    @updateToggle @humanData

  officeHoursTimeout: ->
    now = @officeTimestamp()
    officeOpen = @officeOpenTimestamp() - now
    officeClose = @officeCloseTimestamp() - now
    nextChange = if officeOpen < officeClose then officeOpen else officeClose

    setTimeout =>
      @resetState()
      @officeHoursTimeout()
    , nextChange

  isOutOfOffice: ->
    return false if !@options["outOfOffice"]
    now = @officeTimestamp()
    !(@officeOpenTimestamp() <= now && now <= @officeCloseTimestamp())

  officeOpenTimestamp: ->
    @officeHourToTimestamp "officeOpenHour"

  officeCloseTimestamp: ->
    @officeHourToTimestamp "officeCloseHour"

  officeHourToTimestamp: (hourOptionKey) ->
    hour = @outOfOffice[hourOptionKey]
    advanceDay = hourOptionKey == "officeCloseHour" && @officeHoursOverlapDays()

    if window.moment
      day = moment().tz(@outOfOffice["timezone"]).startOf("day").add hour, "h"
      day.add(1, "d") if advanceDay
      day.valueOf()
    else
      day = utcDate()
      day.setDate(day.getDate() + 1) if advanceDay
      day.setHours hour, 0, 0, 0

  officeHoursOverlapDays: ->
    @outOfOffice["officeOpenHour"] < @outOfOffice["officeCloseHour"]

  officeTimestamp: ->
    if window.moment
      moment().tz(@outOfOffice["timezone"]).valueOf()
    else
      utcDate().getTime()

  debounce: (func, threshold, execAsap) ->
    timeout = null
    (args...) =>
      obj = this
      delayed = ->
        func.apply(obj, args) unless execAsap
        timeout = null
      if timeout
        clearTimeout(timeout)
      else if (execAsap)
        func.apply(obj, args)
      timeout = setTimeout delayed, threshold || 100

  distanceInWords: (fromTime, toTime = (new Date // 1000)) ->
    if fromTime > toTime
      fromTime = toTime
      toTime = fromTime
    distanceInSeconds = toTime - fromTime
    distanceInMinutes = Math.round(distanceInSeconds / 60)

    switch
      when 0 <= distanceInMinutes <= 1
        switch
          when 0 <= distanceInSeconds <= 4 then @timeT "lessThanXSeconds", 5
          when 5 <= distanceInSeconds <= 9 then @timeT "lessThanXSeconds", 10
          when 10 <= distanceInSeconds <= 19 then @timeT "lessThanXSeconds", 20
          when 20 <= distanceInSeconds <= 39 then @timeT "halfAMinute"
          when 40 <= distanceInSeconds <= 59 then @timeT "lessThanXMinutes", 1
          else @timeT "xMinutes", 1
      when 2 <= distanceInMinutes <= 45 then @timeT "xMinutes", distanceInMinutes
      when 45 <= distanceInMinutes <= 90 then @timeT "aboutXHours", 1
      when 90 <= distanceInMinutes <= 1440
        @timeT "aboutXHours", Math.round(distanceInMinutes / 60)
      when 1440 <= distanceInMinutes <= 2520 then @timeT "xDays", 1
      when 2520 <= distanceInMinutes <= 43200
        @timeT "xDays", Math.round(distanceInMinutes / 1440)
      when 43200 <= distanceInMinutes <= 86400
        @timeT "aboutXMonths", Math.round(distanceInMinutes / 43200)
      when 86400 <= distanceInMinutes <= 525600
        @timeT "xMonths", Math.round(distanceInMinutes / 43200)
      else
        remainder = distanceInMinutes % 525600
        distanceInYears = distanceInMinutes // 525600
        if remainder < 131400
          @timeT "aboutXYears", distanceInYears
        else if remainder < 394200
          @timeT "overXYears", distanceInYears
        else
          @timeT "almostXYears", distanceInYears + 1

  timeT: (key, count = null) ->
    translation = @i18n["time"]["distanceInWords"][key] if key of @i18n["time"]["distanceInWords"]
    return unless translation?
    if typeof translation == "object"
      return unless count?
      translation = translation[if count == 1 then "one" else "other"]
    return translation unless count?
    template translation, count: count

  addClass = (el, className) ->
    if el.classList
      el.classList.add className
    else
      el.className += " " + className
    el

  createEl = (type, className, parent) ->
    el = document.createElement type
    addClass el, className
    parent.appendChild el
    return el

  setElText = (el, text) ->
    if typeof el.textContent != undefined
      el.textContent = text
    else
      el.innerText = text

  setElHTML = (el, html) ->
    el.innerHTML = html

  getElDataAttr = (el, attr) ->
    el.getAttribute "data-#{attr}"

  setElDataAttr = (el, attr, val) ->
    el.setAttribute "data-#{attr}", val

  toLocaleStringSupportsLocales = ->
    try new Date().toLocaleString "i"
    catch e then return e instanceof RangeError
    false

  endsWith = (str, suffix) ->
    str.indexOf(suffix, str.length - suffix.length) != -1

  backoff = (n, minimum = 100, limit = 60000) ->
    Math.max Math.min(fib(n) * 1000, limit), minimum

  fib = (n) ->
    if n < 2 then n else fib(n - 1) + fib(n - 2)

  clamp = (n, min, max) ->
    if n <= min then min else if n >= max then max else n

  utcDate = ->
    now = new Date()
    new Date now.getTime() + now.getTimezoneOffset() * 60000

  deepMerge = (target, source) ->
    destination = {}

    for k in (Object.keys(target)).concat(Object.keys(source))
      tv = target[k]
      sv = source[k]

      if sv?
        if typeof sv == "object"
          destination[k] = deepMerge tv || {}, sv || {}
        else
          destination[k] = sv
      else
        destination[k] = tv

    destination

  template = (tpl, args) ->
    tpl.replace /\${(\w+)}/g, (_, v) -> args[v]

  log = (msg, level = "log") ->
    console[level]("[Status Widget] #{msg}")

  warn = (msg) ->
    log msg, "warn"

  error = (msg) ->
    log msg, "error"

window["Status"] = window.Status
window["Status"]["Widget"] = window.Status.Widget
