goog.provide "status.main"

window.Status or= {}

class window.Status.Widget
  _version = "2.1.0"

  constructor: (@options = {}) ->
    requiredOptions = ["hostname", "selector"]
    optionsMissing = !@options?
    optionsMissing = !(o of @options) for o in requiredOptions

    if @options == {} || optionsMissing
      warn "Initialization options missing or invalid."
      return

    defaultOptions = {
      "ssl": true,
      "css": true,
      "debug": false,
      "display": {
        "hideOnError": true,
        "ledOnly": false,
        "panePosition": "bottom-right",
        "ledPosition": "left",
      }
      "i18n": {}
    }

    (@options[k] = v if !@options[k]?) for k, v of defaultOptions

    i18n = {
      "heading": "Issues",
      "loading": "Loading status...",
      "error": "Connection error",
      "issue": {
        "scheduled": "Scheduled",
        "empty": "There are currently no issues."
      },
      "linkBack": "View Status Page"
    }

    (@options["i18n"][k] = v if !@options["i18n"][k]?) for k, v of i18n

    @debug = @options["debug"]
    @hostname = @options["hostname"]
    @display = @options["display"]
    @i18n = @options["i18n"]

    if !/^https?:\/\//i.test(@hostname)
      protocol = (if @options["ssl"] then "https" else "http")
      @hostname = "#{protocol}://#{@hostname}"

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
    @setVisibility "hidden"

    if @elements.widget == null
      warn "Unable to find element with selector: #{widgetSelector}"
      return

    @injectStyles() if @options["css"]
    @connect()

    addClass @elements.widget, "status-widget"

    @elements.led = @createEl "span", @elements.widget, "led"

    @elements.widget.appendChild @elements.led if @display["ledPosition"] != "left"

    unless @display["ledOnly"]
      @elements.state = @createEl "span", @elements.widget, "state"
      setElText @elements.state, @i18n["loading"]

    @elements.pane = @createEl "div", @elements.widget, "pane"
    @elements.pane.dataset.open = false
    @elements.pane.dataset.position = @display["panePosition"]

    @elements.paneHeading = @createEl "strong", @elements.pane, "pane__heading"
    setElText @elements.paneHeading, @i18n["heading"]

    @elements.paneContainer = @createEl "div", @elements.pane, "pane__container"
    @elements.paneText = @createEl "span", @elements.paneContainer, "pane__text"
    setElText @elements.paneText, @i18n["loading"]

    @elements.paneFooter = @createEl "a", @elements.pane, "pane__footer"
    @elements.paneFooter.href = @hostname
    @elements.paneFooter.target = "status"
    setElText @elements.paneFooter, @i18n["linkBack"]

    @elements.widget.addEventListener "click", (e) =>
      e.preventDefault()
      e.stopPropagation()
      state = (@elements.pane.dataset.open == "false")
      @elements.pane.dataset.open = state
    , false

    @elements.pane.addEventListener "click", (e) -> e.stopPropagation()

    document.addEventListener "click", (e) =>
      @elements.pane.dataset.open = false if @elements.pane.dataset.open
    , false

  setVisibility: (visibility) ->
    @elements.widget.style.visibility = visibility

  connect: ->
    if !!window["EventSource"]
      url = @hostname + "/live"
      url += "/#{@options["component"]}" if @options["component"]?
      @source = new window["EventSource"](url)

      @source.onerror = @errorListener
      @source.onopen = @openListener

      @addEventListeners()
    else
      log "Unsupported browser."

  reconnect: (backoff = 0) ->
    clearTimeout @reconnectTimer
    @reconnectTimer = setTimeout =>
      @source.close()
      @connect()
    , backoff

  errorListener: =>
    @reconnectAttempt = 0 unless @reconnectAttempt > 0
    delay = backoff(@reconnectAttempt)
    log "Dropped: Attempting reconnect in #{delay}ms" if @debug
    @reconnect delay
    @reconnectAttempt += 1

    @elements.led.dataset.state = "pending"

    unless @display["hideOnError"]
      @setVisibility "visible"
      connectionLost = delay > 10000
      setElText @elements.state, (if connectionLost then @i18n["error"] else @i18n["loading"]) if @elements.state

  openListener: =>
    @reconnectAttempt = 0
    log "Connected"
    @setVisibility "visible"

  addEventListeners: ->
    eventListeners = {
      "init_event": @initListener,
      "status_event": @statusListener,
      "issue_event": @issueListener,
      "update_event": @updateListener
    }

    for event, listener of eventListeners
      @source.addEventListener event, listener, false

  initListener: (e) =>
    data = @parseEventWithState e

    if "issues" of data
      @issues = {}
      @visibleIssues = []

      for issue in data["issues"]
        @issues[issue["id"]] = issue
        @visibleIssues.push issue["id"] if Object.keys(@issues).length < 5

    @updateIssues()

  statusListener: (e) =>
    data = @parseEventWithState e

  issueListener: (e) =>
    data = @parseEventWithState e

    if "issue" of data
      data["issue"]["updates"] = []
      @issues[data["issue"]["id"]] = data["issue"]

      @visibleIssues.pop() if @visibleIssues.length >= 4
      @visibleIssues.unshift data["issue"]["id"]

    @updateIssues()

  updateListener: (e) =>
    data = @parseEventWithState e

    if "update" of data
      issueId = data["update"]["issue_id"]
      return unless issueId of @issues

      @issues[issueId]["updates"].unshift data["update"]
      @updateIssues()

  parse: (event) ->
    try
      return JSON.parse(event.data) if "data" of event
    catch e
      warn "Received invalid event payload."
    {}

  parseEventWithState: (e) ->
    data = @parse e
    @updateState data.state
    data

  updateState: (state) ->
    state = "pending" if !state?
    @elements.led.dataset.state = state

    if @elements.state?
      text = state
      if "state" of @i18n
        text = @i18n["state"][state] if state of @i18n["state"]

      setElText @elements.state, text

  updateIssues: ->
    @elements.paneContainer.removeChild @elements.paneIssues if @elements.paneIssues?
    @elements.paneIssues = @createEl "div", @elements.paneContainer, "pane__issues"

    if Object.keys(@issues).length == 0
      setElText @elements.paneText, @i18n["issue"]["empty"]
      return

    @elements.paneText.dataset.hidden = true

    for issueId in @visibleIssues
      continue unless issueId of @issues
      @createIssue @issues[issueId]

  createIssue: (issue) ->
    container = @createEl "div", @elements.paneIssues, "issue"

    data = @issueData(issue)

    issueElements = {
      "component": { "el": "strong", "text": issue["component"] },
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

    issueElements["title"].href = "#{@hostname}/issues/#{issue["id"]}"
    issueElements["title"].target = "status"

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

    { body: body, label: label, date: new Date(date * 1000).toLocaleString() }

  createEl: (type, parent, className = undefined) ->
    cssClass = "status-widget"
    cssClass += "__#{className}" if className?
    createEl type, cssClass, parent

  pluralize = (x) -> if x > 1 then "s" else ""

  addClass = (el, className) ->
    if el.classList then el.classList.add className else el.className += " " + className

  createEl = (type, className, parent) ->
    el = document.createElement type
    addClass el, className
    parent.appendChild el
    return el

  setElText = (el, text) ->
    if typeof el.textContent != undefined then el.textContent = text else el.innerText = text

  setElHTML = (el, html) ->
    el.innerHTML = html

  backoff = (n, minimum = 100, limit = 60000) ->
    Math.max Math.min(fib(n) * 1000, limit), minimum

  fib = (n) ->
    if n < 2 then n else fib(n - 1) + fib(n - 2)

  log = (msg, level = "log") ->
    console[level]("[Status Widget] #{msg}")

  warn = (msg) ->
    log msg, "warn"

  error = (msg) ->
    log msg, "error"

window["Status"] = window.Status
window["Status"]["Widget"] = window.Status.Widget
