/* Demo Note:  This demo uses a FileProgress class that handles the UI for displaying the file name and percent complete.
The FileProgress class is not part of SWFUpload.
*/


/* **********************
   Event Handlers
   These are my custom event handlers to make my
   web application behave the way I went when SWFUpload
   completes different tasks.  These aren't part of the SWFUpload
   package.  They are part of my application.  Without these none
   of the actions SWFUpload makes will show up in my application.
   ********************** */
var trackFiles = [];
var trackFilesCount = 0;
var trackSentURL = false;
var forceDone = false;
var forceFile = null;
var master = null;
var MacMinSizeUpload = 150000; // 150k, this is not cool :(
var MacDelay = 10000; // 10 secs.


function fileQueued(file) {
	try {
		var progress = new FileProgress(file, this.customSettings.progressTarget);
		progress.setStatus("Pending...");
		progress.toggleCancel(true, this);

	} catch (ex) {
		this.debug(ex);
	}

}

function fileQueueError(file, errorCode, message) {
	try {
		if (errorCode === SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED) {
			alert("You have attempted to queue too many files.\n" + (message === 0 ? "You have reached the upload limit." : "You may select " + (message > 1 ? "up to " + message + " files." : "one file.")));
			return;
		}

		var progress = new FileProgress(file, this.customSettings.progressTarget);
		progress.setError();
		progress.toggleCancel(false);

		switch (errorCode) {
		case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
			progress.setStatus("File is too big.");
			this.debug("Error Code: File too big, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
			progress.setStatus("Cannot upload Zero Byte files.");
			this.debug("Error Code: Zero byte file, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
			progress.setStatus("Invalid File Type.");
			this.debug("Error Code: Invalid File Type, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		default:
			if (file !== null) {
				progress.setStatus("Unhandled Error");
			}
			this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		}
	} catch (ex) {
        this.debug(ex);
    }
}

function fileDialogComplete(numFilesSelected, numFilesQueued) {
	try {
		this.startUpload();
	} catch (ex)  {
        this.debug(ex);
	}
}

function GetXmlHttpObject() {
  if (window.XMLHttpRequest) {
    return new XMLHttpRequest();
  }
  if (window.ActiveXObject) {
    return new ActiveXObject("Microsoft.XMLHTTP");
  }
  return null;
}

function uploadStart(file) {
	try {
		/* I don't want to do any file validation or anything,  I'll just update the UI and
		return true to indicate that the upload should start.
		It's important to update the UI here because in Linux no uploadProgress events are called. The best
		we can do is say we are uploading.
		 */

    var req = GetXmlHttpObject();
    req.open("GET", '/vzaar/signature', false);
    // This does not work in IE
    //req.overrideMimeType('application/json');
    req.send(null);
    res = json_parse(req.responseText);
    this.customSettings['guid'] = res['guid'];
    this.setPostParams(res);
    this.removePostParam('guid');

		var progress = new FileProgress(file, this.customSettings.progressTarget);
		progress.setStatus("Uploading...");
		progress.toggleCancel(true, this);
    trackFiles[trackFilesCount++] = file.name;
    updateDisplay.call(this, file);
	}
	catch (ex) {}
	
	return true;
}

function uploadProgress(file, bytesLoaded, bytesTotal) {
	try {
		var percent = Math.ceil((bytesLoaded / bytesTotal) * 100);
		var progress = new FileProgress(file, this.customSettings.progressTarget);
    var animPic = document.getElementById("loadanim");

    if (animPic != null) {
      animPic.style.display = 'block';
    }
		progress.setProgress(percent);
		progress.setStatus("Uploading..."+(isMacUser && file.size < MacMinSizeUpload ? ' ...Finishing up, 10 second delay' : ''));
    updateDisplay.call(this, file);


	} catch (ex) {
		this.debug(ex);
	}
}

function uploadSuccess(file, serverData) {
	try {
		var progress = new FileProgress(file, this.customSettings.progressTarget);
		progress.setComplete();
		progress.setStatus("Complete.");
		progress.toggleCancel(false);

    // For some reason the handler is called twice for the first file 
    // in a queue, so to prevent the same file from being uploaded twice
    // we log files that have been already uploaded to the server.
    if (this.customSettings['uploaded_files'].indexOf(file.id) == -1) {
      var req = GetXmlHttpObject();
      params = "guid=" + this.customSettings['guid'];
      params += '&';
      params += "filename=" + encodeURIComponent(file.name);
      req.open("POST", '/vzaar/process_video', true);
      req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
      req.setRequestHeader("Content-length", params.length);
      req.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      req.send(params);
      this.customSettings['uploaded_files'].push(file.id);
    }

	} catch (ex) {
		this.debug(ex);
	}
}

function uploadComplete(file) {
}

function uploadError(file, errorCode, message) {
	try {
		var progress = new FileProgress(file, this.customSettings.progressTarget);
		progress.setError();
		progress.toggleCancel(false);

		switch (errorCode) {
		case SWFUpload.UPLOAD_ERROR.HTTP_ERROR:
			progress.setStatus("Upload Error: " + message);
			this.debug("Error Code: HTTP Error, File name: " + file.name + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.UPLOAD_FAILED:
			progress.setStatus("Upload Failed.");
			this.debug("Error Code: Upload Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.IO_ERROR:
			progress.setStatus("Server (IO) Error");
			this.debug("Error Code: IO Error, File name: " + file.name + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.SECURITY_ERROR:
			progress.setStatus("Security Error");
			this.debug("Error Code: Security Error, File name: " + file.name + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
			progress.setStatus("Upload limit exceeded.");
			this.debug("Error Code: Upload Limit Exceeded, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.FILE_VALIDATION_FAILED:
			progress.setStatus("Failed Validation.  Upload skipped.");
			this.debug("Error Code: File Validation Failed, File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
			progress.setStatus("Cancelled");
			progress.setCancelled();
			break;
		case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
			progress.setStatus("Stopped");
			break;
		default:
			progress.setStatus("Unhandled Error: " + errorCode);
			this.debug("Error Code: " + errorCode + ", File name: " + file.name + ", File size: " + file.size + ", Message: " + message);
			break;
		}
	} catch (ex) {
        this.debug(ex);
    }
}

// This event comes from the Queue Plugin
function queueComplete(numFilesUploaded) {
	var status = document.getElementById("divStatus");
	status.innerHTML = numFilesUploaded + " file" + (numFilesUploaded === 1 ? "" : "s") + " uploaded.";
}


function updateDisplay(file) {

  // isMacUser Patch Begin
  if ( isMacUser ) {
    if (file == null && forceDone) {
      master.cancelUpload(forceFile.id,false);
      pauseProcess(500); // allow flash? to update itself
      master.uploadSuccess(forceFile,null);
      master.uploadComplete(forceFile);
      forceDone = false;
      return;
    }
    // check for small files less < 150k
    // note: dialup users will get bad results.
    if (file.size < MacMinSizeUpload && !forceDone) {
      master = this;
      if (!forceDone) {
        forceFile = file;
        // wait <n> seconds before enforcing upload done!
        setTimeout("updateDisplay("+null+")",MacDelay);
        forceDone = true;
      }
    }
  } // isMacUser Patch End
}


// this should *not* be needed, just testing an idea 
function pauseProcess(millis) {
  var sDate = new Date();
  var cDate = null;

  do { 
    cDate = new Date(); 
  } while(cDate-sDate < millis);
}
