# Status.js
**A live status widget for [Hund.io](https://hund.io/?ref=oss) status pages**

[![License](https://img.shields.io/github/license/hundio/status.js.svg?maxAge=2592000)](https://github.com/hundio/status.js/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/hundio/status.js.svg?maxAge=2592000)](https://github.com/hundio/status.js/releases) [![Code Climate](https://img.shields.io/codeclimate/github/hundio/status.js.svg?maxAge=2592000)](https://codeclimate.com/github/hundio/status.js) [![Codacy grade](https://img.shields.io/codacy/grade/22e2f7f4abf845e988ddf9977f7e400c.svg?maxAge=2592000)](https://www.codacy.com/app/hund/status-js)


## Usage

Add this script to your head or footer: `https://libraries.hund.io/status-js/status-1.0.0.js`

Create an empty element with a selector (e.g. `<div id="status"></div>`) where you want the widget to appear.

Configure the widget:

```javascript
var statusWidget = new Status.Widget({
  status_page: "piedpiper.hund.io",
  selector: "#status"
});
```

### Configuration options

```javascript
{
  status_page: "", // The hostname of your status page
  selector: "", // CSS selector for widget placement
  default_style: true // Whether to inject the default CSS
  pane_position: "bottom-right", // One of "top-left", "top-right", "bottom-left", "bottom-right"
  led_position: "left", // Either "left" or "right"
  component: "", // An individual component's status can be shown by setting this to the ID
  i18n: {
    heading: "Issues",
    loading: "Loading status...",
    scheduled: "Scheduled",
    state: {
      operational: "Operational",
      degraded: "Degraded",
      outage: "Outage",
      pending: "Pending"
    }
  }
}
```
