var PSticker = {
	/**
	 * Prepares all the handlers for the stickers
	 */
	initialize : function () {
		$(".sticker").live("dblclick", function () {
			var text = $(this).text();
			$(this).html('');
			$("<textarea>" + text + "</textarea><input type=\"button\" name=\"update\" value=\"Update\"/><input type=\"button\" name=\"delete\" value=\"Delete\"/>").appendTo($(this));
		});

		$(".sticker input[name='update']").live("click", function() {
			var parent   = $(this).parent();
			var new_text = $(this).siblings("textarea").val();
			PSticker.update_text(parent.attr("data-id"), new_text);
			parent.html(new_text);
		});
		
		$(".sticker input[name='delete']").live("click", function() {
			PSticker.delete_sticker($(this).parent().attr("data-id"));
		});
		
		if (typeof(stickers) !== "undefined" && stickers.length > 0) {
			$.each(stickers, function() {
				PSticker.create_from_data(this._id, this.public, this.text, this.top, this.left);
			});
		}
	},
	
	/**
	 * Sends request to create new sticker
	 */
	make_new : function (book_id, page_number, top, left) {
		if (typeof(top) === "undefined") {
			top = 50;
		}
		if (typeof(left) === "undefined") {
			left = 100;
		}
		var id;
		var sticker_text = prompt("Please, input sticker text below");
		$.ajax({
			async   : false,
			type    : 'post',
			url     : "/stickers.json",
			data    : {
				sticker : {
					page_number : page_number,
					text        : sticker_text,
					top         : top,
					left        : left
				},
				book_id : book_id
			},
			success : function (data) {
				id = data._id;
			}
		});
		
		PSticker.create_from_data(id, true, sticker_text, top, left);
	},
	
	/**
	 * Make new div tag which represents the sticker and inserts it in the DOM
	 */
	create_from_data : function (id, is_public, text, top, left) {
		var public_class = "";
		if (true === is_public) {
			public_class = " public";
		}
		
		var sticker = $("<div class=\"sticker" + public_class + "\">" + text + "</div>");
		sticker.attr("data-id", id);
		sticker.css('top', top);
		sticker.css('left', left);

		$("#book-page-block").append(sticker);

		sticker.draggable({
			stop : function(event, ui) {
				PSticker.update_position($(this).attr("data-id"), ui.position.top, ui.position.left);
			}
		});
	},
	
	/**
	 * Sends request to update sticker's position coordinates
	 * by the given id and the given top and left shifts
	 */
	update_position : function (id, new_top, new_left) {
		$.ajax({
			async : false,
			type  : 'put',
			url   : "/stickers/" + id + ".json",
			data  : { sticker : { top : new_top, left : new_left } }
		});
	},
	
	/**
	 * Sends request to update sticker's text by the given id
	 * and given new text
	 */
	update_text : function (id, new_text) {
		$.ajax({
			async : false,
			type  : 'put',
			url   : "/stickers/" + id + ".json",
			data  : { sticker : { text : new_text } }
		});
	},
	
	/**
	 * Sends request to delete sticker by given identifier
	 * and removes it's div from DOM document
	 */
	delete_sticker : function(id) {
		$.ajax({
			type    : 'delete',
			url     : "/stickers/" + id + ".json",
			success : function (data) {
				$(".sticker[data-id='" + id + "']").remove();
			}
		});
	}
};