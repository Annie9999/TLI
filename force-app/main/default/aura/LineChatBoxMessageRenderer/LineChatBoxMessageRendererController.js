({
	onClickShowMoreMessage: function (component, event, helper) {
		var eventName = component.get("v.eventClickShowMoreName");
		console.log('eventName' + eventName);
		var clickShowMoreMessageEvent = component.getEvent(eventName);
		// clickShowMoreMessageEvent.setParams({ params: true });
		clickShowMoreMessageEvent.fire();
	},
	onClickDownloadFile: function (component, event, helper) {
		console.log('clickDownloadFile');
		var owner = event.currentTarget.getAttribute('data-owner');
		var url = event.currentTarget.getAttribute('data-url');
		if (owner === 'client') {
			var fileName = event.currentTarget.getAttribute('data-fileName');
			var eventName = component.get("v.eventClickDownloadFileName");
			console.log('eventName' + eventName);
			var clickDownloadFileEvent = component.getEvent(eventName);
			var param = {
				url: url,
				file_name: fileName
			};
			clickDownloadFileEvent.setParams({ params: param });
			clickDownloadFileEvent.fire();
		} else {
			console.log(url);
			window.open(url);
		}
	},
	onClickDownloadImage: function (component, event, helper) {
		console.log('onClickDownloadImage');
		var owner = event.currentTarget.getAttribute('data-owner');
		var blob = event.currentTarget.getAttribute('data-blob');
		if (owner === 'client') {
			var fileName = event.currentTarget.getAttribute('data-fileName');
			var eventName = component.get("v.eventClickDownloadImageName");
			console.log('eventName' + eventName);
			var clickDownloadImageEvent = component.getEvent(eventName);
			var param = {
				blob: blob,
				file_name: fileName
			};
			clickDownloadImageEvent.setParams({ params: param });
			clickDownloadImageEvent.fire();
		}
	},
	onClickPreviewImage: function (component, event, helper) {
		console.log('onClickPreviewImage');
		var dataImg = event.currentTarget.getAttribute('data-src')
		var modal = component.find('preview-image');
		$A.util.addClass(modal, 'show-modal');
		component.set('v.dataImg', dataImg);
	},
	onClickClose: function (component, event, helper) {
		console.log('onClickClose');
		component.set('v.dataImg', '');
		$A.util.removeClass(component.find('preview-image'), 'show-modal');
	}
})