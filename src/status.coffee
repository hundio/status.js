goog.provide "status.main"

window.Status or= {}

class window.Status.Widget
  _this = null
  _version = "1.0.1"
  _prefix = "[Status Widget]"
  elements = {}

  constructor: (@options = {}) ->
    _this = this

    required_options = ["status_page", "selector"]
    required_options_missing = !@options?
    required_options_missing = !(o of @options) for o in required_options

    if @options == {} || required_options_missing
      console.warn "#{_prefix} Initialization options missing or invalid, consult the documentation."
      return

    default_options = {
      "ssl": true,
      "default_style": true,
      "pane_position": "bottom-right",
      "led_position": "left",
      "i18n": {}
    }

    (@options[k] = v if !@options[k]?) for k, v of default_options

    i18n = {
      "heading": "Issues",
      "loading": "Loading status...",
      "scheduled": "Scheduled"
    }

    (@options["i18n"][k] = v if !@options["i18n"][k]?) for k, v of i18n

    if !/^https?:\/\//i.test(@options["status_page"])
      protocol = (if @options["ssl"] then "https" else "http")
      @options["status_page"] = "#{protocol}://#{@options["status_page"]}"

    @ready -> _this.attach_widget()

  ready: (fn) ->
    return fn() if document.readyState != "loading"
    document.addEventListener "DOMContentLoaded", fn

  add_styles: ->
    link = document.createElement "link"
    link.rel = "stylesheet"
    link.href = "https://libraries.hund.io/status-js/status-#{_version}.css"
    document.head.appendChild link

  attach_widget: ->
    elements.widget = document.querySelector(@options["selector"])
    elements.widget.style.visibility = "hidden"

    if elements.widget == null
      console.warn "#{_prefix} Unable to find element with selector: #{@options["selector"]}"
      return

    @add_styles() if @options["default_style"]
    @connect()

    add_class elements.widget, "status-widget"

    elements.led = create_el "span", "status-widget__led", elements.widget
    elements.state = create_el "span", "status-widget__state", elements.widget

    elements.widget.appendChild elements.led if @options["led_position"] != "left"

    set_text elements.state, @options["i18n"]["loading"]

    elements.pane = create_el "div", "status-widget--pane", elements.widget
    elements.pane.dataset.open = false
    elements.pane.dataset.position = @options["pane_position"]

    elements.pane_heading = create_el "strong", "status-widget--pane__heading", elements.pane
    set_text elements.pane_heading, @options["i18n"]["heading"]

    elements.pane_container = create_el "div", "status-widget--pane__container", elements.pane
    elements.pane_text = create_el "span", "status_widget--pane__text", elements.pane_container
    set_text elements.pane_text, "Querying monitoring service..."

    elements.pane_footer = create_el "a", "status-widget--pane__footer", elements.pane
    elements.pane_footer.href = @options["status_page"]
    elements.pane_footer.target = "status"
    @update_updated_time(true, true)

    elements.widget.addEventListener "click", (e) ->
      if e.preventDefault then e.preventDefault() else e.returnValue = false
      e.stopPropagation()
      state = (elements.pane.dataset.open == "false")
      _this.update_updated_time() if state
      elements.pane.dataset.open = state
    , false

    elements.pane.addEventListener "click", (e) -> e.stopPropagation()

    document.addEventListener "click", (e) ->
      elements.pane.dataset.open = false if elements.pane.dataset.open
    , false

  connect: ->
    if !!window["EventSource"]
      url = @options["status_page"] + "/live"
      url += "/#{@options["component"]}" if @options["component"]?
      source = new window["EventSource"](url)

      source.onopen = -> elements.widget.style.visibility = "visible"

      @attach_event_listeners source
    else
      console.log "#{_prefix} Unsupported browser."

  attach_event_listeners: (source) ->
    event_listeners = {
      "error": @error_listener,
      "ping_event": @ping_listener,
      "init_event": @initialize_listener,
      "status_event": @status_listener,
      "issue_event": @issue_listener,
      "update_event": @update_listener
    }

    for event, listener of event_listeners
      source.addEventListener event, listener, false

  error_listener: (e) ->
    if e.preventDefault then e.preventDefault() else e.returnValue = false
    if e.readyState == window["EventSource"].CLOSED
      console.log "#{_prefix} Connection closed."
    false

  ping_listener: (e) ->
    if elements.pane.dataset.open == "true"
      _this.updated()

  initialize_listener: (e) ->
    console.log "#{_prefix} Connection established."
    data = _this.parse_event_with_state e

    if "issues" of data
      _this["issues"] = {}
      _this.visible_issues = []

      for issue in data["issues"]
        _this["issues"][issue["id"]] = issue
        _this.visible_issues.push issue["id"] if Object.keys(_this["issues"]).length < 5

    _this.update_issues()

  status_listener: (e) ->
    data = _this.parse_event_with_state e

  issue_listener: (e) ->
    data = _this.parse_event_with_state e

    if "issue" of data
      data["issue"]["updates"] = []
      _this["issues"][data["issue"]["id"]] = data["issue"]

      _this.visible_issues.pop() if _this.visible_issues.length >= 4
      _this.visible_issues.unshift data["issue"]["id"]

    _this.update_issues()

  update_listener: (e) ->
    data = _this.parse_event_with_state e

    if "update" of data
      issue_id = data["update"]["issue_id"]
      return unless issue_id of _this["issues"]

      _this["issues"][issue_id]["updates"].unshift data["update"]
      _this.update_issues()

  parse_event_with_state: (e) ->
    data = parse e
    _this.update_state data.state
    _this.updated()
    data

  update_state: (state) ->
    state = "pending" if !state?
    elements.led.dataset.state = state

    text = state
    if "state" of _this.options["i18n"]
      text = _this.options["i18n"]["state"][state] if state of _this.options["i18n"]["state"]

    set_text elements.state, text

  update_issues: ->
    elements.pane_container.removeChild elements.pane_issues if elements.pane_issues?
    elements.pane_issues = create_el "div", "status_widget--pane__issues", elements.pane_container

    if Object.keys(_this["issues"]).length == 0
      set_text elements.pane_text, "There are currently no issues."
      return

    elements.pane_text.dataset.hidden = true

    for id in _this.visible_issues
      continue unless id of _this["issues"]
      _this.create_issue _this["issues"][id]

  create_issue: (issue) ->
    container = create_el "div", "status_widget--issue", elements.pane_issues

    data = _this.issue_data(issue)

    issue_elements = {
      "component": { type: "strong", text: issue["component"] },
      "title": { type: "a", text: issue["title"] + ": " },
      "body": { type: "p", text: truncate(data.body) },
      "label": { type: "span", text: data.label },
      "time": { type: "span", text: data.date }
    }

    for k, v of issue_elements
      issue_elements[k] = create_el v.type, "status_widget--issue__#{k}", container
      set_text issue_elements[k], v.text

    issue_elements["title"].href = "#{_this.options["status_page"]}/issues/#{issue["id"]}"
    issue_elements["title"].target = "status"

  updated: ->
    _this.updated_time = time()
    _this.update_updated_time(false)

  update_updated_time: (repeat, init) ->
    init = false unless init?
    return if elements.pane.dataset.open == "false" && !init

    _this.updated_time = time() if !_this.updated_time?
    time_diff = time() - _this.updated_time
    set_text elements.pane_footer, "Updated #{timeToStr time_diff} ago"

    repeat = false if !repeat?
    if repeat
      setInterval ->
        _this.update_updated_time(false)
      , 1000

  issue_data: (issue) ->
    standing = !!issue["standing"]
    scheduled = !!issue["scheduled"]
    updates = issue["updates"].length > 0

    if scheduled
      label = _this.options["i18n"]["scheduled"] unless standing
      date = issue["starts_at"]

    issue = issue["updates"][0] if updates

    body = issue["body"]
    label = issue["label"] if standing
    date = issue["created_at"] unless scheduled

    { body: body, label: label, date: new Date(date * 1000).toLocaleString() }

  truncate = (string) ->
    string = string.replace(/<(?:.|\n)*?>/gm, "").replace(/\n/g, " ")
    string.substr(0, 140) + (if string.length > 140 then "\u2026" else "")

  plural = (x) -> if x > 1 then "s" else ""

  time = -> new Date().getTime()

  timeToStr = (t) ->
    temp = Math.floor(t / 1000)
    hours = Math.floor((temp %= 86400) / 3600)
    if hours then return hours + " hour" + plural(hours)
    minutes = Math.floor((temp %= 3600) / 60)
    if minutes then return minutes + " minute" + plural(minutes)
    seconds = temp % 60
    if seconds then return seconds + " second" + plural(seconds)
    "<1 second"

  add_class = (el, className) ->
    if el.classList then el.classList.add className else el.className += " " + className

  create_el = (type, className, parent) ->
    el = document.createElement type
    add_class el, className
    parent.appendChild el
    return el

  set_text = (el, text) ->
    if typeof el.textContent != undefined then el.textContent = text else el.innerText = text

  parse = (event) ->
    try
      return JSON.parse(event.data) if "data" of event
    catch e
      console.warn "#{_prefix} Received invalid event payload."
    {}

window["Status"] = window.Status
window["Status"]["Widget"] = window.Status.Widget
