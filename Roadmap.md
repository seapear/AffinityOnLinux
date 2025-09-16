# 🗺️ Roadmap

[ ✅ ] Get the whole winmetadata thing sorted out. ( [Issue #6](https://github.com/Twig6943/AffinityOnLinux/issues/6) )

[ ✅ ] Fix crashes upon saving/exporting

[ ✅ ] Get the font issue fixed (related to flatpak)

[ ✅ ] Settings workaround

[ ❌ ] Get canva login fixed (thanks XDan for reporting)

[ ❌ ] Get vector issue solved (Thanks Søren for reporting)

[ 🟨 ] Get [studiolink](https://github.com/Twig6943/AffinityOnLinux/issues/25) working

[ ❌ ] OpenCL for Amd/Intel gpus (waiting ElementalWarrior)

[ ❌ ] Video walkthrough tutorials.
 - [ ❌ ] Lutris Method.
 - [ ❌ ] Heroic Method.
 - [ ❌ ] Bottles Method.
 - [ ❌ ] RUM Method.

# ⚠️ Known Issues
Some users get these errors with the script but are able to get it working with the guide method

- wine: could not load ntdll.so: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.38' not found (required by /home/USER/.AffinityLinux/ElementalWarriorWine/bin/../lib/wine/x86_64-unix/ntdll.so)

- wine: could not load `mscoree.dll` or any crash related to .NET Framework while using bottles
    - This is probably caused by Wine Mono conflicting with the installation of .NET Framework versions lower than 5.  
    As of now, it does not seem possible to specify the removal of Wine Mono as an instruction in the yaml manifest, since bottles does not use winetricks under the hood, but their own dependency manager.
    For a working install in bottles, one would have to create a custom empty bottle, then uninstall Wine Mono before anything else, then manually install dependencies.  
    This defeats the purpose of having an automated bottle creation using yaml files, so bottles is currently not recommended.  
    - Sources: 
      - [Bottles issue #2887](https://github.com/bottlesdevs/Bottles/issues/2887#issuecomment-2646118028)  
      - [Wine Mono README](https://github.com/wine-mono/wine-mono#:~:text=Please%20note%20that%20while%20Wine%20Mono%20should%20always%20be%20removed%20before%20installing%20.NET%20Framework%204.8%20and%20earlier%2C%20it%20can%20coexist%20with%20.NET%20Core%20and%20.NET%205%20or%20later.)

- ZorinOS not working atm.
