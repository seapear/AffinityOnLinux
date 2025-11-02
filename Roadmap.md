# 🗺️ Roadmap

[ ✅ ] Host a local download for ElementalWarriors and TKG Wine Builds

[ ✅ ] Get the whole winmetadata thing sorted out. ( [Issue #6](https://github.com/Twig6943/AffinityOnLinux/issues/6) )

[ ✅ ] Fix crashes upon saving/exporting

[ ✅ ] Get the font issue fixed (related to flatpak)

[ ✅ ] Settings workaround

[ ❌ ] Create an updated Wine build utilizing latest version of wine.

[ ❌ ] Get Canva login fixed (thanks XDan for reporting)

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

- Affinity by Canva: Sign in issues with Canva [Reported](https://discord.com/channels/1281706644073611358/1281706644715208809/1433584942167887942)
- Affinity by Canva: Pen path is still an issue. ([V3](https://cdn.discordapp.com/attachments/1281706644715208809/1433663104826474577/image.png?ex=69058250&is=690430d0&hm=832e2549f694a92a1bec29310cea5ea4c1a2a309b23dfef56c83649d55bf188e&)) [V2](https://discord.com/channels/1281706644073611358/1325725311836622944)
- Affinity by Canva: Color picker doesn't want to work outside of the canvas/artboards. [@_dansity_](https://discord.com/channels/1281706644073611358/1433758899122471012) [Clover](https://discord.com/channels/1281706644073611358/1433758899122471012/1433783910126321747)
- Affinity by Canva: Vector Pen preview line is not accurate. [Reported](https://discord.com/channels/1281706644073611358/1433830414954397736)
- Designer V2: Deselecting SVG nested in Group while snapping is enabled. [Jacopo Faust](https://discord.com/channels/1281706644073611358/1431672689843634377)

- V2 Users getting their 40x font pack as a "gift" [Youtube - Affinity](https://www.youtube.com/watch?v=UP_TBaKODlw&t=1300s)


