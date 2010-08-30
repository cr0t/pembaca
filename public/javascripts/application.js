$(function () {
	if ($('.notice').length > 0) {
		setTimeout("$(\".notice\").animate({\"opacity\" : 0 }, 'slow', function () { $(this).remove(); });", 5000);
	}
	if ($("#my-bookshelf").length > 0) {
		setTimeout(updateMyBookshelf, 5000);
	}
});

function updateMyBookshelf() {
	$.getScript("/uploads.js");
	setTimeout(updateMyBookshelf, 5000);
}