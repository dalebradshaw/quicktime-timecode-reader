{
var proj = app.project;

if (proj) {

app.beginUndoGroup("Get QuickTime Timecode INfo");
// loop through all items selected in project window

for (var a = 0; a < proj.selection.length; ++a) {

thisItem = proj.selection[a];

// check item is footage and is not a still image

if (thisItem instanceof FootageItem && !thisItem.mainSource.isStill) {

		var timecode = system.callSystem("~/bin/timecodereader " + String(thisItem.mainSource.file));
		if(timecode){
			writeLn(String(thisItem.name));
			writeLn("tc:" + timecode);
		}else{
			writeLn("could not access timecodereader");
		}

  }
}

app.endUndoGroup();
  }
}