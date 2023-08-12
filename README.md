![electroniz3r-small](https://github.com/r3ggi/electroniz3r/assets/15366054/80a5cddf-438e-4ca2-9108-7000cd905b3c)

# electroniz3r
Take over macOS Electron apps' TCC permissions

## Overview

```
$ electroniz3r
OVERVIEW: macOS Red Teaming tool that allows code injection in Electron apps
 by Wojciech Reguła (@_r3ggi)

USAGE: electroniz3r <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list-apps               List all installed Electron apps
  inject                  Inject code to a vulnerable Electron app
  verify                  Verify if an Electron app is vulnerable to code injection

  See 'electroniz3r help <subcommand>' for detailed help.
```

### list-apps

```
$ electroniz3r list-apps
╔══════════════════════════════════════════════════════════════════════════════════════════════════════╗
║    Bundle identifier                      │       Path                                               ║
╚──────────────────────────────────────────────────────────────────────────────────────────────────────╝
com.microsoft.VSCode                         /Applications/Visual Studio Code.app
com.vmware.fusionApplicationsMenu            /Applications/VMware Fusion.app/Contents/Library/VMware Fusion Applications Menu.app
notion.id                                    /Applications/Notion.app
com.github.GitHubClient                      /Applications/GitHub Desktop.app
com.logi.optionsplus                         /Applications/logioptionsplus.app
com.microsoft.teams                          /Applications/Microsoft Teams.app
com.tinyspeck.slackmacgap                    /Applications/Slack.app
```

### verify

```
$ electroniz3r verify "/Applications/GitHub Desktop.app"
/Applications/GitHub Desktop.app started the debug WebSocket server
The application is vulnerable!
You can now kill the app using `kill -9 7033`
```

### inject

```
$ electroniz3r help inject
OVERVIEW: Inject code to a vulnerable Electron app

USAGE: electroniz3r inject <path> [--path-js <path-js>] [--predefined-script <predefined-script>]

ARGUMENTS:
  <path>                  Path to the Electron app

OPTIONS:
  --path-js <path-js>     Path to a file containing JavaScript code to be executed
  --predefined-script <predefined-script>
                          Use predefined JS scripts (calc, screenshot, stealAddressBook, bindShell, takeSelfie)
  -h, --help              Show help information.
```
