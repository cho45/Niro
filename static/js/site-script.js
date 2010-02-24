Deferred.define();

Niro = {};
Niro.Editor = function () { this.init.apply(this, arguments) };
Niro.Editor.prototype = {
	init : function () {
	}
};

$(function () {
	$("#content .hentry").each(function () {
		var $entry    = $(this);
		var $title    = $entry.find('.entry-title');
		var $content  = $entry.find('.entry-content');
		var $info     = $entry.find('.entry-info');
		var permalink = $entry.find('a[rel="bookmark"]').attr('href');
		var entry_id  = permalink.match(/(\d+)$/)[1];

		$('<a href="' + permalink +'#edit" class="admin">Edit</a>').insertAfter($title).click(function () {
			var $edit = $(this);
			$edit.hide();

			try {
			
			var title   = $('<input type="text" size="50" disabled="disabled" value="loading..."/>');
			var content = $('<div/>');

			var body   = $('<textarea cols="50" rows="10" disabled="disabled">loading...</textarea>');
			var tools  = $('<div/>');
			var ok     = $('<input type="button" value="Save" disabled="disabled"/>');
			var cancel = $('<input type="button" value="Cancel"/>');
			tools.append(ok, cancel);
			content.append(body, tools)

			cancel.click(function () {
				$edit.show();
				title.replaceWith($title);
				content.replaceWith($content);
			});

			chain(
				function () {
					$title.replaceWith(title);
					$content.replaceWith(content);

					return $.getJSON(Niro.BASE + "/api/info?id=" + entry_id);
				},
				function (data) {
					title.val(data.entry.title).removeAttr('disabled');
					body.val(data.entry.body).removeAttr('disabled');
					ok.removeAttr('disabled');

					return ok.deferred('click');
				},
				function () {
					ok.attr('disabled', 'disabled');

					return $.post(Niro.BASE + '/api/post', {
						id    : entry_id,
						title : title.val(),
						body  : body.val(),
						rks   : Niro.User.rks
					}, null, "json");
				},
				function (data) {
					$title.html(data.entry.title);
					$content.html(data.entry.formatted_body);
					cancel.click();
				},
				function error (e) {
					cancel.click();
					alert(e);
				}
			);
			
			} catch (e) { alert(e) }
			

			return false;
		});
	});
});
