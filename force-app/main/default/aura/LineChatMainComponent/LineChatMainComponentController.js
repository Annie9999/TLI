({
    onInit: function (component, event, helper) {
      component.set('v.isFinishedLoadJquery', true);
      console.log('Init');
      var transferObtion = {
        People: {
          // objectAPIName: 'User', IconName: 'standard:avatar', condition: 'AND IsActive = true AND Profile.Name IN (\'Sansiri Telesale\',\'Sansiri Call Centre\')',
          objectAPIName: 'User', IconName: 'standard:avatar', condition: 'WHERE IsActive = true',
          selectedValue: null, hasLastViewedDate: true
        },
        Queue: {
          // objectAPIName: 'Group', IconName: 'standard:groups', condition: 'AND Type = \'Queue\' And Name like \'%Chat%\'',
          objectAPIName: 'Group', IconName: 'standard:groups', condition: 'WHERE Type = \'Queue\'',
          selectedValue: null, hasLastViewedDate: false
        }
      };
      var selectedTransferObtionKey = component.get('v.selectedTransferObtionKey');
      component.set('v.selectedTransferObtion', transferObtion[selectedTransferObtionKey]);
      component.set('v.transferObtion', transferObtion);
  
      helper.getInitData(component, event, helper);
    },
    onRender: function (component, event, helper) {
      console.log("---entry in render---");
      if (!component.get('v.isFinishedLoadJquery')) {
        return;
      }
      var isMoveTop = component.get('v.isMoveTop');
      console.log('isMoveTop ' + isMoveTop);
      console.log('playNotifyInboundSound ' + component.get("v.playNotifyInboundSound"));
      if (!isMoveTop) {
        helper.moveBottomScrollbar(component);
      } else {
        helper.moveTopScrollbar(component);
      }
  
      // var chatCollectionByDate = component.get('v.chatCollectionByDate');
      // if(chatCollectionByDate !== undefined && chatCollectionByDate !== null){
      //     helper.moveBottomScrollbar(component); 
      //     console.log("---entry in render in if---");
      //     // $('#id-container').scrollTop($('#id-container')[0].scrollHeight);
      // }
    },
    onClickSendMessage: function (component, event, helper) {
      component.set('v.isMoveTop', false);
      helper.sendMessage(component, event, helper);
    },
    onKeyPressMessage: function (component, event, helper) {
      component.set('v.isMoveTop', false);
      if (event.which == 13) {
        helper.sendMessage(component, event, helper);
      }
    },
    handleShowmoreMessage: function (component, event, helper) {
      console.log('handleShowmoreMessage');
      component.set('v.isMoveTop', true);
      helper.getMoreData(component, event, helper);
    },
    handleDownloadFile: function (component, event, helper) {
      console.log('handleDownloadFile');
      var param = event.getParam("params");
      helper.downloadFileFromLine(component, helper, param['url'], param['file_name']);
    },
    handleDownloadImage: function (component, event, helper) {
      console.log('handleDownloadImage');
      var param = event.getParam("params");
      helper.downloadImageFromLine(component, helper, param['blob'], param['file_name']);
    },
    onClickEndChat: function (component, event, helper) {
      component.set('v.isOpenEndChat', true);
    },
    onClickWrapUpChat: function (component, event, helper) {
      component.set('v.isOpenWrapUpChat', true);
    },
    onClickCancelEndChat: function (component, event, helper) {
      helper.clearEndChatInformation(component);
    },
    onClickSubmitEndChat: function (component, event, helper) {
      // var endChatValue = component.get("v.endChatValue");
      // var chatTopicValue = endChatValue.chatTopicValue;
      // console.dir(JSON.stringify(chatTopicValue));
      // var othersInput = endChatValue.othersInput;
      // if (!chatTopicValue || chatTopicValue.length == 0) {
      //   component.set('v.endChatErrorMessage', 'Please fill in chat topic.');
      //   return;
      // }
      // if (chatTopicValue.includes('Others') && !othersInput) {
      //   component.set('v.endChatErrorMessage', 'Please fill in the others chat topic.');
      //   return;
      // }
      // if (!chatTopicValue.includes('Others')) {
      //   component.set("v.endChatValue.othersInput", '');
      //   component.set('v.endChatValue.isOthersInputDisabled', true);
      // }
      helper.saveEndChatInformation(component, event, helper);
    },
    onClickTransferChat: function (component, event, helper) {
      component.set('v.isOpenTransferChat', true);
    },
    onChangeChatTopicRadio: function (component, event, helper) {
      var values = event.getParam("value");
      if (values.includes('Others')) {
        component.set('v.endChatValue.isOthersInputDisabled', false);
      } else {
        component.set('v.endChatValue.isOthersInputDisabled', true);
      }
  
    },
    onSelectTransferObtions: function (component, event, helper) {
      var selectedMenuItemValue = event.getParam("value");
      component.set('v.selectedTransferObtionKey', selectedMenuItemValue);
      var transferObtion = component.get('v.transferObtion');
      component.set('v.selectedTransferObtion', transferObtion[selectedMenuItemValue]);
      // console.dir(JSON.stringify(transferObtion[selectedMenuItemValue]));
      // console.dir(JSON.stringify(transferObtion[selectedMenuItemValue].objectAPIName));
    },
    onClickCancelTransferChat: function (component, event, helper) {
      helper.clearTransferChatInformation(component);
    },
    onClickSubmitTransferChat: function (component, event, helper) {
      var selectedTransferObtionKey = component.get('v.selectedTransferObtionKey');
      var transferObtion = component.get('v.transferObtion');
      var newOwnerTransfer = transferObtion[selectedTransferObtionKey].selectedValue;
  
      if (newOwnerTransfer === undefined || newOwnerTransfer === null) {
        component.set('v.transferChatErrorMessage', 'Please choose new owner.');
        return;
      }
  
      helper.saveTransferChatInformation(component, event, helper, newOwnerTransfer);
    },
    // onClickDownLoadFile: function (component, event, helper) {
    //   helper.downloadFileFromLine(component, event, helper);
    // }
    handleUploadFinished: function (component, event, helper) {
      // Get the list of uploaded files
      var uploadedFiles = event.getParam("files");
      // alert("Files uploaded : " + uploadedFiles[0].name + " " + uploadedFiles[0].documentId);
      helper.sendImageAndFile(component, event, helper, uploadedFiles[0].documentId);
      // use apex get this document
    },
  
  })