Deferred.define();

Niro = {};
Niro.Entry = function () { this.init.apply(this, arguments) };
Niro.Entry.prototype = {
	init : function (hentry, opts) {
		if (!opts) opts = {};

		var self = this;
		self.opts      = opts;
		self.$entry    = $(hentry);
		self.$title    = self.$entry.find('.entry-title');
		self.$content  = self.$entry.find('.entry-content');
		self.$info     = self.$entry.find('.entry-info');
		self.$bookmark = self.$entry.find('a[rel="bookmark"]');
		self.permalink = self.$bookmark.attr('href');
		self.entry_id  = self.permalink.match(/(\d+)$/)[1];
		self.editLink  = self.$entry.find('a[href$="edit"]');
		if (!self.editLink.size())
			self.editLink = $('<a href="' + self.permalink +'#edit" class="admin">Edit</a>');

		self.editLink.insertAfter(self.$title).click(function () {
			self.edit();
			return false;
		});

		if (self.opts.newEntry) {
			self.$bookmark.html("#");
			self.$title.empty();
			self.$content.empty();
			self.$info.html("Not saved");
			self.permalink = null;
			self.entry_id  = null;
			self.edit();
		}
	},

	edit : function () {
		var self = this;
		self.editLink.hide();

		var $title   = self.$title;
		var $content = self.$content;

		var title    = $('<input type="text" size="80" disabled="disabled" value="loading..."/>');
		var content  = $('<div/>');

		var body   = $('<textarea cols="50" rows="10" disabled="disabled">loading...</textarea>');
		var tools  = $('<div/>');
		var ok	 = $('<input type="button" value="Save" disabled="disabled"/>');
		var cancel = $('<input type="button" value="Cancel"/>');
		tools.append(ok, cancel);
		content.append(body, tools)

		body.css("width", "100%");

		cancel.click(function () {
			if (!self.entry_id) {
				self.$entry.remove();
			} else {
				self.editLink.show();
				title.replaceWith($title);
				content.replaceWith($content);
			}
		});
		

		chain(
			function () {
				$title.replaceWith(title);
				$content.replaceWith(content);

				if (self.opts.newEntry) {
					return next(function () { return {
						entry :  {
							title : "",
							body  : ""
						}
					} });
				} else {
					return $.getJSON(Niro.BASE + "/api/info?id=" + self.entry_id);
				}
			},
			function (data) {
				title.val(data.entry.title).removeAttr('disabled');
				body.val(data.entry.body).removeAttr('disabled');
				ok.removeAttr('disabled');

				return ok.deferred('click');
			},
			function () {
				ok.attr('disabled', 'disabled');

				var data = {
					title : title.val(),
					body  : body.val(),
					rks   : Niro.User.rks
				};
				if (!self.opts.newEntry)
					data.id = self.entry_id;

				return $.post(Niro.BASE + '/api/post', data, null, "json");
			},
			function (data) {
				self.entry_id = data.entry.id;
				$title.html(data.entry.title);
				$content.html(data.entry.formatted_body);
				cancel.click();
			},
			function error (e) {
				alert(e);
				cancel.click();
			}
		);
	}
};

Niro.setupEditLinks = function () {
	$(".hfeed .hentry").each(function () {
		new Niro.Entry(this);
	});
};


Niro.setupCreateLink = function () {
	var $hfeed = $(".hfeed");
	$("<a href='#create'>New Entry</a>").prependTo($hfeed).click(function () {
		var $hentry = $hfeed.find('.hentry').clone(true);
		$hentry.prependTo($hfeed);
		var newEntry = new Niro.Entry($hentry[0], { newEntry : true });
	});

	// var $entry = $(".hentry");
};

$(function () {

	if (Niro.User.login) {
		Niro.setupEditLinks();
		Niro.setupCreateLink();
	}
});
