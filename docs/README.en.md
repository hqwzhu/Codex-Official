# Codex Provider Switcher

Codex Provider Switcher is a small Windows desktop utility for switching Codex between:

- Official OpenAI / ChatGPT account mode.
- Third-party CCswitch / Freemodel API mode.

It is designed for people who use Codex with an official ChatGPT plan sometimes, but also use a third-party API gateway for other work. The tool keeps the two connection modes separate and makes switching a button click instead of a manual config edit.

## Pain Point

Codex can be used with different authentication paths:

- Official ChatGPT account login, which uses the Codex access included in a ChatGPT plan.
- API-key based custom providers, such as CCswitch or Freemodel.

Without a switcher, users often edit `~/.codex/config.toml` manually, change environment variables by hand, or overwrite the wrong credential. This is slow and risky: one typo can break Codex startup, and mixing official and third-party credentials can make it unclear which account is being used.

## Solution

This project adds a local GUI app with four actions:

- Use Official ChatGPT.
- Use CCswitch.
- Connection Status.
- Re-login ChatGPT.

The app updates only the active Codex provider settings, creates backups before switching, and keeps credentials separate:

- CCswitch mode uses `FREEMODEL_API_KEY`.
- Official mode uses Codex's built-in `openai` provider and ChatGPT account login.

No API key is stored in this repository.

## Download

Option 1: clone with Git.

```powershell
git clone https://github.com/hqwzhu/Codex-Official.git
cd Codex-Official
```

Option 2: download ZIP from GitHub.

1. Open `https://github.com/hqwzhu/Codex-Official`.
2. Click `Code`.
3. Click `Download ZIP`.
4. Extract the ZIP.

## Install

Requirements:

- Windows 10 or Windows 11.
- Codex CLI installed and available in `PATH`.
- For CCswitch mode: `FREEMODEL_API_KEY` configured in the user or machine environment.
- For official mode: Codex logged in with `Sign in with ChatGPT`.

Run the installer from the project folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1
```

The installer creates:

- Desktop shortcut: `Codex Provider Switcher`.
- Start menu shortcut: `Codex Provider Switcher`.
- Installed files under `%USERPROFILE%\.codex\provider-switch`.

## Usage

Open `Codex Provider Switcher` from the Desktop or Start menu.

- Click `Use Official ChatGPT` to switch Codex to the official OpenAI provider and ChatGPT account login mode.
- Click `Use CCswitch` to switch Codex to the CCswitch/Freemodel provider.
- Click `Connection Status` to check the current provider, key availability, and Codex login state.
- Click `Re-login ChatGPT` if Codex still shows an API-key login and you want to restore official ChatGPT account login.

After switching, restart any already-open Codex window so it reloads `config.toml`.

## Uninstall

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\installer\uninstall.ps1
```

The uninstaller removes the app shortcut and installed app files. It does not remove your Codex `config.toml`, environment variables, or Codex login credentials.
