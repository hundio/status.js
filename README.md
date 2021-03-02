# Status.js
**A live status widget for [Hund.io](https://hund.io/?ref=oss) status pages**

![Preview](https://libraries.hund.io/status-js/preview.png)

[![License](https://img.shields.io/github/license/hundio/status.js.svg?maxAge=2592000)](https://github.com/hundio/status.js/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/hundio/status.js.svg?maxAge=2592000)](https://github.com/hundio/status.js/releases) [![Maintainability](https://api.codeclimate.com/v1/badges/a16f7b24c756af9f1363/maintainability)](https://codeclimate.com/github/hundio/status.js/maintainability)


## Usage

Add this script to your head or footer:

```html
<script src="https://libraries.hund.io/status-js/status-3.8.2.js"></script>
```

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
  privacyBypassToken: "", // A Privacy Bypass Token to allow visitors to view this widget without additional authentication (requires the Privacy Control upgrade)
  includePrivacyBypassTokenInLinks: false, // Include the given Privacy Bypass Token in any widget links to the status page, so that visitors can view the status page itself through the widget without additional authentication
  css: true, // Inject the default CSS styles
  debug: false, // Log debugging messages
  outOfOffice: false, // Toggles out of office status change (see section below)
  linkTarget: "_blank", // The link target for outbound links (see https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a#attr-target)
  display: {
    hideOnError: true, // Hide the widget if a connection cannot be established
    pane: true, // Display the pane dropdown
    paneStatistics: true, // Display pane statistics (i.e. uptime, incident-free streak)
    ledOnly: false, // Show only the LED indicator, hiding the status text
    panePosition: "bottom-right", // One of "top-left", "top-right", "bottom-left", "bottom-right"
    ledPosition: "left", // Either "left" or "right"
    statistic: {
      uptimeDecimals: 4 // Number of decimals for uptime pane statistic
      minIncidentFreeStreak: 86400 // Minimum number of incident free streak seconds required to display
    },
    outOfOffice: {
      resetStatusLed: false, // Sets the status LED indicator to it's default gray color
      officeOpenHour: 0, // An integer representing the hour (24-hour, UTC if no timezone)
      officeCloseHour: 24, // An integer representing the hour (24-hour, UTC if no timezone)
      timezone: "" // See the section below for setting a timezone
    }
  },
  i18n: {
    heading: "Issues",
    toggle: "${state}", // Other variables: percentUptime and incidentFreeStreak
    loading: "Loading status...",
    error: "Connection error",
    statistic: {
      streak: "No events for ${duration}!",
      uptime: "${percent}% Uptime"
    },
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
      pending: "Pending",
      outOfOffice: "Out of Office"
    },
    linkBack: "View Status Page",
    dates: { // See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleString#Parameters
      locale: "",
      options: {}
    },
    time: {
      distanceInWords: {
        halfAMinute: "half a minute",
        lessThanXSeconds: {
          one: "less than 1 second",
          other: "less than ${count} seconds"
        },
        xSeconds: {
          one: "1 second",
          other: "${count} seconds"
        },
        lessThanXMinutes: {
          one: "less than a minute",
          other: "less than ${count} minutes"
        },
        xMinutes: {
          one: "1 minute",
          other: "${count} minutes"
        },
        aboutXHours: {
          one: "about 1 hour",
          other: "about ${count} hours"
        },
        xDays: {
          one: "1 day",
          other: "${count} days"
        },
        aboutXMonths: {
          one: "about 1 month",
          other: "about ${count} months"
        },
        xMonths: {
          one: "1 month",
          other: "${count} months"
        },
        aboutXYears: {
          one: "about 1 year",
          other: "about ${count} years"
        },
        overXYears: {
          one: "over 1 year",
          other: "over ${count} years"
        },
        almostXYears: {
          one: "almost 1 year",
          other: "almost ${count} years"
        }
      }
    }
  }
}
```

### Out of office status

You may wish to display an "out of office" status when outside of business hours. To do so, set the `outOfOffice` option to `true`, then configure the feature within the `display` object as seen above.

#### Timezone support

By default, UTC is used. [Moment Timezone](https://momentjs.com/timezone/) (with data) must be included on pages if you wish to use a specific timezone and respect DST changes. It will be used when detected. Specify a timezone as so:

```javascript
var statusWidget = new Status.Widget({
  hostname: "example.hund.io",
  selector: "#status",
  outOfOffice: true,
  display: {
    outOfOffice: {
      officeOpenHour: 9,
      officeCloseHour: 17,
      timezone: "America/Los_Angeles"
    }
  }
});
```
