$(function () {
	if ($("#my-bookshelf").length > 0) {
		setTimeout(updateMyBookshelf, 5000);
	}
});

function updateMyBookshelf() {
	$.getScript("/uploads.js");
	setTimeout(updateMyBookshelf, 5000);
}