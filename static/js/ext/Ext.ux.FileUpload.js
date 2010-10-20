/**
 * File upload panel
 */
Ext.namespace('Ext.ux');
  
Ext.ux.FileUploadPanel = function( cfg ) {
	Ext.apply( this,cfg );

	var uploadIdentifier = Ext.ux.util.MD5(new Date());

	/** Buttons */
	this.cancelButton = new Ext.Button({
		text: 'Cancel',
		disabled: true,
		minWidth: 20,
		listeners: {
			'click': this.stopProgress, scope: this
		}
	});

	this.uploadButton = new Ext.Button({
		text: 'Upload',
		disabled: true,
		minWidth: 20
	});

    this.browseButton = new Ext.form.FileUploadField({
		name: 'path',
		hideLabel: true,
		buttonOnly: true,
		columnWidth: 0.10,
		listeners: {
			'fileselected': function( fb,v ) {
				this.uploadButton.enable();
				this.fileNameField.setValue( v );
			}, scope: this
		}
	});

	/**
    this.uploadButtonPanel = new Ext.Panel({
      items: [this.uploadButton]
    });
	*/

    var progressBar = new Ext.ProgressBar({
	  text: "Progress",
    });

    this.fileNameField = new Ext.form.TextField({
      name: 'display-path',
      hideLabel: true
    });

    this.progressTask = {
      run: function() {
        Ext.Ajax.request({
          url: this.uri +"/progress",
          method: 'GET',
		  headers: {'X-Progress-ID': uploadIdentifier},
          success: function(r) {

            if (r.responseText == 'null') {
              return;
            }

			//console.log( r );
            var response 	= Ext.decode( r.responseText );
			//console.log( response );

			//var total		= 0;
			//var uploaded	= 0;
			//var progress	= 0;
			if( response.state == "uploading" ){
            	var total 	 = parseInt(response.size);
            	var uploaded = parseInt(response.received);
            	var progress = ( uploaded/total );
            	this.progressBar.updateProgress( progress,Math.round(100*progress)+'% completed...', true);
			}
			//console.log( "Progress: "+progress );
		  	//console.log( r );
          }
        });
      },
      interval: 5000, 
      scope: this
    };

    this.progressTaskRunner = new Ext.util.TaskRunner();

	Ext.ux.FileUploadPanel.superclass.constructor.call( this,{
		frame: true,
		layout:	'fit',
		bodyStyle: 'padding:5px 5px 0',
		baseParams: {'X-Progress-ID': uploadIdentifier},
		fileUpload: true,
		items: [{
			layout: 'form',
			items:  [{
  				layout: 'column',
  				defaults: {columnWidth: .25},
  				items: [{
					xtype: 'hidden',
					name: 'X-Progress-ID',
					value: uploadIdentifier
  				}, this.browseButton, this.fileNameField, this.uploadButton, this.cancelButton ]
			}]
		}, progressBar]
	});

	this.uploadButton.on('click', function( button ) {
		var form = this.getForm();
		if( !form.isValid() ) {
			return false;
		}

		var fileName = this.fileNameField.getValue();
		if(fileName == ""){
			return false;
		}

		//console.log( this.filenameCheckUrl );
		//console.log( config.uploadto );
        Ext.Ajax.request({
			url: 	this.uri +"/check_for_filename",
			scope: 	this,
			params:	{ filename: fileName },
			method:	'GET',
			success: function(r) {
				if( r.responseText == 'null' ) { return; }
				//if( r.responseText.match( /^new/ )){ return; }

            	var response 	= Ext.decode(r.responseText);

				if( response.count > 0 ){
					Ext.Msg.alert( "Filename error", "A file with this name already exists on the system." );
					return false;
				}
				//console.log( response );

        		progressBar.updateProgress( 0,' ',false );

        		button.disable();
        		this.cancelButton.enable();
        		this.startProgress();

        		form.submit({
          			//url: this.uri +"?X-Progress-Id="+ uploadIdentifier,
          			url: this.uri, 
          			scope: this,

          			success: function( form,res ) {
						//console.log( res );
            			progressBar.updateProgress( 1,'100% complete',true );
            			this.stopProgress();
            			button.enable();

						var json	= Ext.decode( res.response.responseText );
						this.complete( json );
          			},

					failure: function( form,action ) {
						console.log( action );
            			//this.stopProgress();
            			//button.enable();
          			}
        		});
			}
        });
	}, this );    

};
  
Ext.extend( Ext.ux.FileUploadPanel,Ext.form.FormPanel, {
//Ext.extend( Ext.ux.FileUploadPanel,Ext.Panel, {
	startProgress: function() {
		this.progressTaskRunner.start(this.progressTask)
	},

	stopProgress: function() {
		this.progressTaskRunner.stopAll();
	}
});

