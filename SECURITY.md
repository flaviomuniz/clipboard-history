# Security Policy

ClipboardHistory stores everything you copy, so security bugs matter here more than in most small apps.

## Supported Versions

There are no versioned releases yet. Security fixes go into the latest commit on `main`. If you built the app from an older commit, rebuild from `main` before reporting.

| Version | Supported |
| ------- | --------- |
| Latest `main` | Yes |
| Older commits | No |

## Reporting a Vulnerability

Please don't open a public issue for a security problem.

Report it privately through GitHub instead:

1. Go to the [Security tab](https://github.com/flaviomuniz/clipboard-history/security) of this repository.
2. Click **Report a vulnerability**.
3. Describe the problem, how to reproduce it, and which macOS version and commit you used.

You should get a first reply within a week. If the report is confirmed, the fix lands on `main` and you'll be credited in the advisory unless you'd rather not be.

## Scope

In scope: anything that exposes clipboard history to another app or user, saves copies the app should skip (password-manager copies, ignored apps), or makes the app send data off the machine.

Out of scope: someone with access to your unlocked Mac and user account reading `~/Library/Application Support/ClipboardHistory/history.json`. The history is stored as plain JSON, as the README says.
