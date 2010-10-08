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

String.prototype.repeat = function (num) {
	for (var i = 0, buf = ""; i < num; i++) {
		buf += this;
	}
	return buf;
}
String.prototype.ljust = function (width, padding) {
	padding = padding || " ";
	padding = padding.substr(0, 1);
	if (this.length < width) {
		return this + padding.repeat(width - this.length);
	}
	else {
		return this;
	}
}
String.prototype.rjust = function (width, padding) {
	padding = padding || " ";
	padding = padding.substr(0, 1);
	if (this.length < width) {
		return padding.repeat(width - this.length) + this;
	}
	else {
		return this;
	}
}
String.prototype.center = function (width, padding) {
	padding = padding || " ";
	padding = padding.substr(0, 1);
	if (this.length < width) {
		var len    = width - this.length;
		var remain = (len % 2 == 0) ? "" : padding;
		var pads   = padding.repeat(parseInt(len / 2, 10));
		return pads + this + pads + remain;
	}
	else {
		return this;
	}
}
