# _archive

Dormant Nix modules. Not imported anywhere in the active configuration.

These modules previously existed in the live tree but were toggled off
via commented imports. They are kept here for reference and quick revival
rather than relying solely on `git log`.

To reactivate a module:

```bash
git mv modules/_archive/<path> modules/<original-path>
```

Then re-add its import line in `hosts/nixos/default.nix` or
`modules/home-manager/profiles/desktop.nix` as appropriate.
