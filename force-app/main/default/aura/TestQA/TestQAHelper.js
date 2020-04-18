({
	/*getQuestion : function(component, event,helper) {
		console.log('-----getQuestion-----');
		var opptyId =  component.get("v.recordId");
		var questGroup =  component.get("v.questGroup");
		
		var action = component.get("c.getQuest");
        action.setParams({ 
            "opptyId": opptyId,
            "questGroup": questGroup
		});
		
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var returnVal = response.getReturnValue();

				console.log('Return questions: ',JSON.parse(JSON.stringify(returnVal)));

			


				//if(returnVal.Answer == ''){
					//var ans = component.get('',"v.answers");

				//	component.set("v.answers" ,returnVal.Answer);


			//	}
				




			}

		});
        $A.enqueueAction(action)  

	},

	save: function(component, event,helper) {
		console.log('-----save-----');
		var msg ='Are you sure ?';
        if (confirm(msg)) {

			var opptyId =  component.get("v.recordId");
			var questGroup =  component.get("v.questGroup");
			var quesList =  component.get('v.questions');  

			var ansList = [];
				quesList.forEach((element, index, array) => {
					// console.log('element',element);
					ansList.push(element.TmpAnswser);
				} );
				console.log('opptyId: '+opptyId);
				console.log('ques: ',JSON.parse(JSON.stringify(quesList)));
				console.log('ans: ',JSON.parse(JSON.stringify(ansList)));


				var action = component.get("c.saveQA");
				action.setParams({ 
					"opptyId": opptyId,
					"quesList": quesList,
					"ansList": ansList,
					"questGroup": questGroup
				});
				action.setCallback(this, function(response) {
					var state = response.getState();
					if (state === "SUCCESS") {
						$A.get('e.force:refreshView').fire();
						
					}
				});
				$A.enqueueAction(action)
                 

		}


	}*/
})