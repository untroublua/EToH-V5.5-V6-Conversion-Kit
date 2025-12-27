# INSTRUCTIONS
To use this, first make sure that the place you are running this script in is the EToH-supplied v6.1.1 kit place.

In preparation for the conversion:
- Paste the v5.5 tower in the Workspace.
- You will have to move the custom client objects out of your tower, then convert them afterwards.
- You will have to move the kit away from your original tower if it overlaps.

Then, paste the following code below into your command bar.

`require(game:FindFirstChild("KIT-MIGRATE-v6", true))`

<<<-------------------------------------------------------------------------------------------------------->>>

# NOTICE
The converter has **NO COMPATIBILITY** with CUSTOM CLIENT OBJECTS or *(some)* NESTED CLIENT OBJECTS!
This also includes client objects that were considered custom before the release of Kits v6+.

You can only convert one tower at a time, which means you cannot convert whole fangames with this kit.

Additionally, this script converts directly from Version 5.5 to Version 6.1.1.
Any version preceding or following it is subject to issues. You can reach later versions by using the EToH team's update kits.
This notice will be updated as this script gets changes.

If this script encounters an exception at any point during the conversion, no changes will have been made to your tower.
But, you'll have to reinsert the script.

You will also have to manually convert any modified ClientObject(s). (they are not deleted on convert, unless you toggle the corresponding setting)

This script is provided as-is, with no official maintenance from the EToH staff team (yet?). Use at your own risk.
Though, for now, it may be maintained by either terriac or untroublua.