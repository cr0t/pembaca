var FBViewer = {
	page_el               : "#page",
	controls_container_el : "#controls-container",
	controls_el           : "#controls",
	
	controls_max_height : 100,
	controls_min_height : 0, // 20px padding gives us some place at top
	controls_pinned     : false,
	
	book         : {},
	shost        : null,
	current_page : null,
	
	init : function (data) {
		FBViewer.book  = data;
		FBViewer.shost = data.static_host;
		
		FBViewer.controls_init();
		
		$.address.change(function(event) {
			FBViewer.check_page($.address.parameter("page")) && FBViewer.show_page();
		});
	},
	
	controls_init : function () {
		$(FBViewer.controls_container_el).mouseover(function () {
			FBViewer.show_controls();
		});
		
		$(FBViewer.controls_container_el).mouseout(function () {
			FBViewer.hide_controls();
		});
		
		$("#pin-toggler").click(function () {
			if (false === FBViewer.controls_pinned) {
				FBViewer.controls_pinned = true;
				$(this).css({ background : "rgba(128, 255, 128, 0.8)"});
			}
			else {
				FBViewer.controls_pinned = false;
				$(this).css({ background : "rgba(255, 255, 255, 0.2)"});
			}
		});
		
		$("#prev-page-button").click(function () {
			$.address.parameter("page", FBViewer.current_page - 1);
		});
		$("#next-page-button").click(function () {
			$.address.parameter("page", FBViewer.current_page + 1);
		});
	},
	
	show_controls : function () {
		$(FBViewer.controls_el).show();
		$(FBViewer.controls_container_el).stop().animate({
			"height" : FBViewer.controls_max_height
		});
	},
	
	hide_controls : function () {
		if (false === FBViewer.controls_pinned) {
			$(FBViewer.controls_container_el).stop().animate({
				"height" : FBViewer.controls_min_height
			}, function () {
				$(FBViewer.controls_el).hide()
			});
		}
	},
	
	pin_controls : function () {
		FBViewer.controls_pinned = true;
	},
	
	unpin_controls : function () {
		FBViewer.controls_pinned = false;
	},
	
	check_page : function (page_number) {
		page_number = parseInt(page_number, 10);
		
		if (
			page_number > 0
			&& page_number <= FBViewer.book.total_pages
			&& false == isNaN(page_number)
		) {
			FBViewer.current_page = page_number;
			return true;
		}
		
		$(FBViewer.page_el).html('<div class="page-error">There is no such page in this book!</div>');
		
		return false;
	},
	
	show_page : function () {
		console.log("current_page: " + FBViewer.current_page);
		
		if (FBViewer.current_page) {
			page_number = FBViewer.current_page + "";

			var img_url = "http://" + FBViewer.shost + "/";
			img_url += FBViewer.book._id + "/";
			img_url += FBViewer.book._id + "-" + page_number.rjust(6, "0") + ".png";
			$(FBViewer.page_el).html('<img src="' + img_url + '"/>');
		}
	}
};

// Store the function in a global property referenced by a string:
window['FBViewer'] = FBViewer;