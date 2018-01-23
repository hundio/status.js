# Status.js
**A live status widget for [Hund.io](https://hund.io/?ref=oss) status pages**

![Preview](https://libraries.hund.io/status-js/preview.png)

[![License](https://img.shields.io/github/license/hundio/status.js.svg?maxAge=2592000)](https://github.com/hundio/status.js/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/hundio/status.js.svg?maxAge=2592000)](https://github.com/hundio/status.js/releases) [![Code Climate](https://img.shields.io/codeclimate/github/hundio/status.js.svg?maxAge=2592000)](https://codeclimate.com/github/hundio/status.js)


## Usage

Add this script to your head or footer: `https://libraries.hund.io/status-js/status-2.3.5-compat.js`

Create an empty element with a selector (e.g. `<div id="status"></div>`) where you want the widget to appear.

Configure the widget:

```html
<script>
  var statusWidget = new Status.Widget({
    hostname: "example.hund.io",
    selector: "#status"
  });
</script>
```

### Configuration options

```javascript
{
  hostname: "", // The hostname of your status page (custom domains supported)
  component: "", // Show a specific component's status by providing its id
  selector: "", // CSS selector of an existing element for widget placement
  css: true, // Inject the default CSS styles
  debug: false, // Log debugging messages
  display: {
    hideOnError: true, // Hide the widget if a connection cannot be established
    pane: true, // Display the pane dropdown
    ledOnly: false, // Show only the LED indicator, hiding the status text
    panePosition: "bottom-right", // One of "top-left", "top-right", "bottom-left", "bottom-right"
    ledPosition: "left", // Either "left" or "right"
  },
  i18n: {
    dates: { // See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleString#Parameters
      locale: "",
      options: {}
    },
    heading: "Issues",
    loading: "Loading status...",
    error: "Connection error",
    issue: {
      scheduled: "Scheduled",
      empty: {
        operational: "There are currently no reported issues."
        degraded: "There are currently no reported issues, but we have detected that at least one component is degraded."
        outage: "There are currently no reported issues, but we have detected outages on at least one component."
      }
    },
    state: {
      operational: "Operational",
      degraded: "Degraded",
      outage: "Outage",
      pending: "Pending"
    },
    linkBack: "View Status Page"
  }
}
```
