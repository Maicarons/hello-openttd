# FAQ

## Windows

**Q: SmartScreen says "Windows protected your PC".**
A: The launcher isn't code-signed yet. Choose "More info → Run anyway", build from source yourself, or wait for signed builds.

**Q: Antivirus flags the launcher.**
A: It writes outside its own directory (data root) and starts game processes, which heuristics dislike. Whitelist the launcher folder; persistent false positives → file an Issue with a diagnostic bundle.

**Q: Game complains about missing DLLs.**
A: Official OpenTTD bundles its runtimes. For custom-source builds install the VC++ redistributable (vc_redist.x64).

## Linux

**Q: Launcher won't start, GTK/GLib errors.**
A: Flutter Linux builds need GTK3: `sudo apt install libgtk-3-0 libblkid1 liblzma5` (Debian/Ubuntu; similar package names elsewhere).

**Q: Version install fails extracting `.tar.xz`.**
A: On Linux the launcher delegates `.tar.xz` to the system `tar`; make sure xz/tar are installed (any modern distro has them).

## macOS

**Q: "Cannot open because the developer cannot be verified".**
A: Unsigned until M7. Right-click → Open, or `xattr -cr /Applications/OpenDepot.app`. See [Installation](./install#macos).

**Q: Fullscreen / resolution issues in game.**
A: Adjust in the game's Video Options, or pass `-r` on the launch page.

## Downloads & network

**Q: Downloads keep failing or crawling.**
A: ① Settings → Downloads → re-probe; ② add a custom mirror ([guide](./downloads#adding-a-custom-mirror)); ③ switch to "Official only" to isolate mirror issues.

**Q: Resume didn't kick in — it restarted from zero.**
A: Remote file changed (length/ETag) or the mirror lacks Range support; restarting prevents corrupted assemblies.

**Q: SHA-256 verification failed.**
A: Don't dismiss it — corrupted download or poisoned mirror. Retry from the official source; if that fails too, attach logs in an Issue.

## Versions & config

**Q: Do saves transfer between official and JGRPP?**
A: Mostly yes (saves are backward compatible), but JGRPP-specific settings/content may behave differently. Back up before crossing versions.

**Q: I already installed OpenTTD manually — can the launcher adopt it?**
A: Yes: "Add local version" points at the existing game directory; the launcher writes a manifest without moving anything.

**Q: I broke the config and the game won't start.**
A: Every editor save leaves a `.bak`; restore from the config page. Worst case, delete `openttd.cfg` and let the game regenerate it.

**Q: Where do mods installed from inside the game go?**
A: Same directories the launcher uses (`content_download/…`); the mod center picks them up.

## Misc

**Q: Does the launcher collect my data?**
A: No telemetry, no analytics; network access only when you trigger it.

**Q: Mobile support?**
A: No plans; desktop three-platform first.

**Q: Question not answered?**
A: Ask in [Discussions](https://github.com/hello-openttd/hello-openttd/discussions) or file an Issue per the [contributing guide](https://github.com/hello-openttd/hello-openttd/blob/main/CONTRIBUTING.md).
