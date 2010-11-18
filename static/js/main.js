var map;
$(document).ready(function(){
	$("#hour_slider").slider({
		min: 0,
		max: 24,
		step: 1,
		value: 17,
		slide: function(event, ui) {
			updateToD();
		}
	});

	$("#minute_slider").slider({
		min: 1,
		max: 60,
		step: 5,
		value: 30,
		slide: function(event, ui) {
			updateToD();
		}
	});

	$("#btnUpdate").click(function(){ updateMap(); });

	updateToD();
	updateMap();
});

function updateToD(){
	var meridian = "AM";

	var hour = $("#hour_slider").slider("value");
	var minute = $("#minute_slider").slider("value");

	if(hour <= 9){
		hour = "0"+hour;
	}
	if(hour > 12){
		hour -= 12;
		meridian = "PM";
	}

	if(minute <= 9){
		minute = "0"+minute;
	}

	$("#tod").html( hour+":"+minute+" "+meridian );
}

function updateMap(){
	var hour = $("#hour_slider").slider("value");
	var minute = $("#minute_slider").slider("value");
	var highway = $("select[name=highway]").val();

	//console.log( day );
	//console.log( todHour );
	//console.log( todMinute );

	$.ajax({
		url: '/predict',
		data: { todHour: hour, todMinute: minute, highway: highway },
		type: 'POST',
		dataType: 'json',
		success: function( res ){

			var myLatLng = new google.maps.LatLng( res.data[0].start[0],res.data[0].start[1] );
			var myOptions = {
				zoom: 12,
				center: myLatLng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			};
			map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

			//console.log( res );
			res.data.forEach(function( r ){
				var pLine = new google.maps.Polyline({
					path: [
						new google.maps.LatLng( r.start[0],r.start[1] ),
						new google.maps.LatLng( r.end[0],r.end[1] )
					],
					strokeColor: r.color,
					strokeWeight: 4,
					storkeOpacity: 1.0
				});
				pLine.setMap( map );

				var marker = new google.maps.Marker({
					map: map,
					title: r.name +" :: "+ r.readings,
					position: new google.maps.LatLng( r.start[0],r.start[1] )
				});
			});
		}
	});
}
