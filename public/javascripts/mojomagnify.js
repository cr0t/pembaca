/*
 * MojoMagnify 0.1.7 - JavaScript Image Magnifier
 * Copyright (c) 2008 Jacob Seidelin, cupboy@gmail.com, http://blog.nihilogic.dk/
 * Licensed under the MPL License [http://www.nihilogic.dk/licenses/mpl-license.txt]
 */


var MojoMagnify = (function() {

	var $ = function(id) {return document.getElementById(id);};
	var dc = function(tag) {return document.createElement(tag);};

	var isIE = !!document.all && !!window.attachEvent && !window.opera;

	function addEvent(element, ev, handler) 
	{
		var doHandler = function(e) {
			return handler(e||window.event);
		}
		if (element.addEventListener) { 
			element.addEventListener(ev, doHandler, false); 
		} else if (element.attachEvent) { 
			element.attachEvent("on" + ev, doHandler); 
		}
	}
	
	function removeEvent(element, ev)
	{
		if (element.removeEventListener) { 
			element.removeEventListener(ev); 
		} else if (element.detachEvent) { 
			element.detachEvent("on" + ev); 
		}
	}

	function getElementPos(element)
	{
		var x = element.offsetLeft;
		var y = element.offsetTop;
		var parent = element.offsetParent;
		while (parent) {
			x += parent.offsetLeft;
			y += parent.offsetTop;
			parent = parent.offsetParent;
		}
		return {
			x : x,
			y : y
		}
	}

	function getEventMousePos(element, e) {
		var scrollX = document.body.scrollLeft || document.documentElement.scrollLeft;
		var scrollY = document.body.scrollTop || document.documentElement.scrollTop;

		if (e.currentTarget) {
			var pos = getElementPos(element);
			return {
				x : e.clientX - pos.x + scrollX,
				y : e.clientY - pos.y + scrollY
			}
		}
		return {
			x : e.offsetX,
			y : e.offsetY
		}
	}

	function setZoomPos(img, x, y, pos) {
		var zoomImg = img.__mojoMagnifyImage;
		if (!zoomImg) return;

		var full = img.__mojoMagnifyOptions.full;

		img.__mojoMagnifyX = x;
		img.__mojoMagnifyY = y;
		img.__mojoMagnifyPos = pos;

		var zoom = img.__mojoMagnifyZoomer;

		var maskWidth = zoom.offsetWidth;
		var maskHeight = zoom.offsetHeight;

		var imgLeft = img.offsetLeft;
		var imgTop = img.offsetTop;
		var w = img.offsetWidth;
		var h = img.offsetHeight;


		if (full) {
			var fx = x / img.offsetWidth;
			var fy = y / img.offsetHeight;

			var dw = maskWidth - img.offsetWidth;
			var dh = maskHeight - img.offsetHeight;

			var left = -dw * fx; 
			var top = -dh * fy;
		} else {
			var left = pos.x - maskWidth/2;
			var top = pos.y - maskHeight/2;

			if (!isIE) {
				left -= imgLeft;
				top -= imgTop;
			}
		}

		zoom.style.left = left + "px";
		zoom.style.top = top + "px";

		if (full) {
			var zx = 0;
			var zy = 0;
		} else {
			var zoomXRatio = zoomImg.offsetWidth / w;
			var zoomYRatio = zoomImg.offsetHeight / h;

			var zoomX = Math.round(x * zoomXRatio);
			var zoomY = Math.round(y * zoomYRatio);

			var zx = -zoomX + maskWidth/2;
			var zy = -zoomY + maskHeight/2;
		}

		zoomImg.style.left = zx + "px";
		zoomImg.style.top = zy + "px";
	}

	function startAnimation(img) {
		var options = img.__mojoMagnifyOptions;

		if (img.__mojoMagnifyAnimTimer)
			clearTimeout(img.__mojoMagnifyAnimTimer);
		var step = 1;

		var zoom = img.__mojoMagnifyZoomer;
		var zoomImg = img.__mojoMagnifyImage;
		var zoomBorder = img.__mojoMagnifyBorder;

		var imgWidth = img.offsetWidth;
		var imgHeight = img.offsetHeight;

		var dw = img.__mojoMagnifyWidth - imgWidth;
		var dh = img.__mojoMagnifyHeight - imgHeight;

		var next = function() {
			var w = imgWidth + dw * (step/10);
			var h = imgHeight + dh * (step/10);

			zoomBorder.style.width = w + "px";
			zoomBorder.style.height = h + "px";
			zoom.style.width = w + "px";
			zoom.style.height = h + "px";
			zoomImg.style.width = w + "px";
			zoomImg.style.height = h + "px";

			if (img.__mojoMagnifyPos) {
				setZoomPos(img, img.__mojoMagnifyX, img.__mojoMagnifyY, img.__mojoMagnifyPos);
			}

			if (step < 10) {

				step += 1;
				img.__mojoMagnifyAnimTimer = setTimeout(next, 60);
			} else {
				img.__mojoMagnifyAnimTimer = 0;
			}
		}
		next();
	}

	function makeMagnifiable(img, zoomSrc, opt) {
		var options = opt || {};

		img.__mojoMagnifyOptions = options;

		// make sure the image is loaded, if not then add an onload event and return
		if (!img.complete && !img.__mojoMagnifyQueued) {
			addEvent(img, "load", function() {
				img.__mojoMagnifyQueued = true;
				setTimeout(function() {
					makeMagnifiable(img, zoomSrc);
				}, 1);
			});
			return;
		}

		var w = img.offsetWidth;
		var h = img.offsetHeight;

		var oldParent = img.parentNode;
		if (oldParent.nodeName.toLowerCase() != "a") {
			var linkParent = dc("a");
			//linkParent.setAttribute("href", zoomSrc);
			linkParent.setAttribute("href", "javascript:void();");
			oldParent.replaceChild(linkParent, img);
			linkParent.appendChild(img);
		} else {
			var linkParent = oldParent;
		}

		linkParent.style.position = "relative";
		linkParent.style.display = "block";
		linkParent.style.width = w+"px";
		linkParent.style.height = h+"px";

		var imgLeft = img.offsetLeft;
		var imgTop = img.offsetTop;

		var zoom = dc("div");
		zoom.className = "mojomagnify_zoom";
		zoom.style.left = "-9999px";

		var parent = img.parentNode;
		var zoomImg = dc("img");
		zoomImg.className = "mojomagnify_img";
		zoomImg.style.position = "absolute";

		if (isIE) { 
			// IE won't let the mouse click pass through properly to the link,
			// so we clone the link and use it for the zoom image as well. Do for all browsers, perhaps?
			var zoomLink = dc("a");
			zoomLink.setAttribute("href", linkParent.getAttribute("href"));
			zoomLink.setAttribute("onclick", linkParent.getAttribute("onclick"));
			zoomLink.style.position = "absolute";
			zoomLink.style.left = "0px";
			zoomLink.style.top = "0px";
			zoomLink.appendChild(zoomImg);
			zoom.appendChild(zoomLink);
		} else {
			zoom.appendChild(zoomImg);
		}

		var ctr = dc("div");
		with (ctr.style) {
			position = "absolute";
			left = imgLeft+"px";
			top = imgTop+"px";
			width = w+"px";
			height = h+"px";
			overflow = "hidden";
			display = "block";
		}


		ctr.appendChild(zoom);
		parent.appendChild(ctr);

		var zoomBorder = dc("div");
		zoomBorder.className = "mojomagnify_border";
		zoom.appendChild(zoomBorder);

		var zoomInput = parent;

		// clear old overlay
		if (img.__mojoMagnifyOverlay)
			parent.removeChild(img.__mojoMagnifyOverlay);
		img.__mojoMagnifyOverlay = ctr;

		// clear old high-res image
		if (img.__mojoMagnifyImage && img.__mojoMagnifyImage.parentNode)
			img.__mojoMagnifyImage.parentNode.removeChild(img.__mojoMagnifyImage);

		img.__mojoMagnifyImage = zoomImg;
		img.__mojoMagnifyZoomer = zoom;
		img.__mojoMagnifyBorder = zoomBorder;

		var isInImage = false;

		addEvent(zoomImg, "load", function() {

			var onMouseOut = function(e) {
				var target = e.target || e.srcElement;
				if (!target) return;
				if (target.nodeName != "DIV") return;
				var relTarget = e.relatedTarget || e.toElement;
				if (!relTarget) return;
				while (relTarget != target && relTarget.nodeName != "BODY" && relTarget.parentNode) {
					relTarget = relTarget.parentNode;
				}
				if (relTarget != target) {
					isInImage = false;
					ctr.style.display = "none";
				}
			};

			addEvent(ctr, "mouseout", onMouseOut);
			addEvent(ctr, "mouseleave", onMouseOut);
			if (isIE) {
				addEvent(document.body, "mouseover",
					function(e) {
						if (isInImage && e.toElement != zoomImg) {
							ctr.style.display = "none";
						}
					}
				);
			}
			
			addEvent(zoomInput, "mousemove", 
				function(e) {
					if (!isInImage) {
						if (options.animate) {
							startAnimation(img);
						}
					}
					isInImage = true;

					ctr.style.display = "block";

					var pos = getEventMousePos(zoomInput, e);

					if (e.srcElement && isIE) {
						if (e.srcElement == zoom) return;
						if (e.srcElement != zoomInput) {
							var zoomImgPos = getElementPos(e.srcElement);
							var imgPos = getElementPos(img);
							pos.x -= (imgPos.x - zoomImgPos.x);
							pos.y -= (imgPos.y - zoomImgPos.y);
						}
					}

					var x = e.clientX - (getElementPos(img).x - (document.body.scrollLeft||document.documentElement.scrollLeft));
					var y = e.clientY - (getElementPos(img).y - (document.body.scrollTop||document.documentElement.scrollTop));

					setZoomPos(img, x, y, pos);
				}
			);

			if (options.full) {
				var maskWidth = zoomImg.offsetWidth;
				var maskHeight = zoomImg.offsetHeight;
				img.__mojoMagnifyWidth = maskWidth;
				img.__mojoMagnifyHeight = maskHeight;
				zoomBorder.style.width = maskWidth + "px";
				zoomBorder.style.height = maskHeight + "px";
				zoom.style.width = maskWidth + "px";
				zoom.style.height = maskHeight + "px";
			}

			ctr.style.display = "none";
		});

		// I've no idea. Simply setting the src will make IE screw it self into a 100% CPU fest. In a timeout, it's ok.
		setTimeout(function() { 
			zoomImg.src = zoomSrc;
		}, 1);
	}

	function setCoords(img, x, y) {
		if (!img.__mojoMagnifyOverlay) return;
		isInImage = true;
		img.__mojoMagnifyOverlay.style.display = "block";
		setZoomPos(img, x, y, { x : x, y : y });
	}

	function init() {
		var images = document.getElementsByTagName("img");
		var imgList = [];
		for (var i=0;i<images.length;i++) {
			imgList.push(images[i]);
		}
		for (var i=0;i<imgList.length;i++) {
			var img = imgList[i];
			var zoomSrc = img.getAttribute("data-magnifysrc");
			if (zoomSrc) {
				var opt = {
					full : img.getAttribute("data-magnifyfull") === "true",
					animate : img.getAttribute("data-magnifyanimate") === "true"
				};
				makeMagnifiable(img, zoomSrc, opt);
			}
		}
	}

	return {
		addEvent : addEvent,
		init : init,
		makeMagnifiable : makeMagnifiable,
		setCoords : setCoords
	};

})();

MojoMagnify.addEvent(window, "load", MojoMagnify.init);