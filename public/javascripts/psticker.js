var PSticker = {
	initialize : function () {
		$(".sticker").live("dblclick", function () {
			var text = $(this).text();
			$(this).html('');
			$("<textarea>" + text + "</textarea><input type=\"button\" value=\"Update\"/>").appendTo($(this));
		});

		$(".sticker input[type=button]").live("click", function() {
			var parent   = $(this).parent();
			var new_text = $(this).siblings("textarea").val();
			PSticker.update_text(parent.attr("data-id"), new_text);
			parent.html(new_text);
		});
		
		if (typeof(stickers) !== "undefined" && stickers.length > 0) {
			$.each(stickers, function() {
				PSticker.create_from_data(this._id, this.text, this.top, this.left);
			});
		}
	},
	
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
		
		PSticker.create_from_data(id, sticker_text, top, left);
	},
	
	create_from_data : function (id, text, top, left) {
		var sticker = $("<div class=\"sticker\">" + text + "</div>");
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
	
	update_position : function (id, new_top, new_left) {
		$.ajax({
			async   : false,
			type    : 'put',
			url     : "/stickers/" + id + ".json",
			data    : { sticker : { top : new_top, left : new_left } }
		});
	},
	
	update_text : function (id, new_text) {
		$.ajax({
			async   : false,
			type    : 'put',
			url     : "/stickers/" + id + ".json",
			data    : { sticker : { text : new_text } }
		});
	}
};