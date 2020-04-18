({
	mergeTemplate : function(template,row,callback,component,helper) {
       console.log('mergeTemplate: START');
    
       component.set("v.fetchUser",false);
       component.set("v.fetchObject",false);
        
       let keyList = helper.parseTemplate(template);
       console.log('mergeTemplate: keyList extracted',keyList);
        
        if (! keyList) {
            console.warn('mergeTemplate: no merge keys found in template',template);
            callback(template,null);
            return;
        }
        
        let sObjectName = component.get("v.sObjectName") || 'Undefined';
        console.log('mergeTemplate: sObjectName fetched',sObjectName); 
        let fetchUser   = false;
        let fetchObject = false;
        let mergedTemplate = template;
        (Object.keys(keyList)).forEach(function(keyItem){
            console.log('mergeTemplate: processing keyItem',keyItem);
            switch (keyItem) {
                case "User" :
                    let currentUser = helper.getCurrentUser();
                    console.log('mergeTemplate: currentUser',JSON.stringify(currentUser));
                    if (helper.compareLists(Object.keys(keyList["User"]),
                                            Object.keys(currentUser))) {
                       mergedTemplate = helper.mergeFields(mergedTemplate,
                                                           keyList["User"],
                                                           currentUser);
                       console.log('mergeTemplate: mergedTemplate updated with User',mergedTemplate);
                    } else {
                       console.log('mergeTemplate: missing User fields for immediate merge');
                       fetchUser = true;
                       component.set("v.userId",currentUser.Id);
                       component.set("v.userFields",Object.keys(keyList["User"]));
                       console.log('mergeTemplate: userFields set',Object.keys(keyList["User"]));
                    }
                    break;
                case "Object" :
                    fetchObject = true;
                    component.set("v.objectFields",Object.keys(keyList["Object"]));
                    console.log('mergeTemplate: objectFields set',Object.keys(keyList["Object"]));
                    break;
                case "sObjectName" :
                    mergedTemplate = helper.mergeFields(mergedTemplate,
                                                        keyList["sObjectName"],
                                                        {"default":component.get("v.sObjectName")});
                    console.log('mergeTemplate: mergedTemplate updated with sObjectName',mergedTemplate);
                    break;
                case "recordId" :
                    console.log('mergeTemplate: recordId',component.get("v.recordId"));
                    mergedTemplate = helper.mergeFields(mergedTemplate,
                                                        keyList["recordId"],
                                                        {"default":component.get("v.recordId") });
                    console.log('mergeTemplate: mergedTemplate updated with recordId',mergedTemplate);
                    break;
                case "Row" :
                    mergedTemplate = helper.mergeFields(mergedTemplate,
                                                        keyList["Row"],
                                                        row);
                    console.log('mergeTemplate: mergedTemplate updated with Row',mergedTemplate);
                    break;
                case "Context" :
                    let contextData = (component.find("contextMgr")).getValue();    
                    mergedTemplate = helper.mergeFields(mergedTemplate,
                                                        keyList["Context"],
                                                        contextData);
                    console.log('mergeTemplate: mergedTemplate updated with Context',mergedTemplate);
                    break;
                case "Now" : 
                    mergedTemplate = helper.mergeFields(mergedTemplate,
                                                        keyList["Now"],
                                                        {"default":(new Date()).toISOString()});
                    console.log('mergeTemplate: mergedTemplate updated with Now',mergedTemplate);
                    break;
                case "Label" : 
                    // WORK IN PROGRESS
                    /*
                    let labelValues = helper.getLabels(keyList["Label"],component);
                    mergedTemplate = helper.mergeFields(mergedTemplate,
                                                        keyList["Label"],
                                                        labelValues);
                    console.log('mergeTemplate: mergedTemplate updated with Label',mergedTemplate);
                    break; */
                default :
                    console.error('mergeTemplate: unsupported key found in template',keyItem);
                    callback(null,[{"message":"Unsupported key found in template : " + keyItem}]);
                    //console.log('mergeTemplate: error callback triggered');
                    return;
            }
        });
        
        
        if (!(fetchUser || fetchObject)) {
            console.log('mergeTemplate: merge completed',mergedTemplate);
            callback(mergedTemplate,null);
            return;
        } else {
            console.log('mergeTemplate: additional User/Object info required for merge');
            component.set("v.context",{"mergedTemplate": mergedTemplate,
                                       "fetchUser": fetchUser,
                                       "userKeys": keyList["User"],
                                       "fetchObject": fetchObject,
                                       "objectKeys": keyList["Object"],
                                       "callback": callback });
            component.set("v.fetchUser",fetchUser);
            component.set("v.fetchObject",fetchObject);
        }
       
        console.log('mergeTemplate: END');
    },
    parseTemplate : function(template) {
        console.log('parseTemplate: template',template);
        
        let regexp = /\{\{\{\s*(\w*[\.\w*]*)\s*\}\}\}/gi;
        console.log('parseTemplate: regexp',regexp);
        let mergeKeys = template.match(regexp);
        console.log('parseTemplate: mergeKeys', mergeKeys);

        if (! mergeKeys) {
            console.log('parseTemplate: END / no mergeKeys found');
            return null;
        }
        
        console.log('parseTemplate: mergeKeys not null');
        let mergeFields = {};
        mergeKeys.forEach(function(keyItem){
           console.log('parseTemplate: processing keyItem',keyItem);
           //let keyParts = ((keyItem.replace(/\{|\}/gi,'')).trim()).split('.');
           let keyParts = ((keyItem.replace(/\{|\}/gi,'')).trim());
           let splitIndex = keyParts.indexOf('.');
           //console.log('parseTemplate: keyParts extracted',keyParts);
           console.log('parseTemplate: splitIndex determined',splitIndex);
           let mainKey, fieldKey = '';
           if (splitIndex == -1) {
               mainKey  = keyParts;
               fieldKey = 'default';
           } else {
               mainKey  = keyParts.substring(0, splitIndex);
               fieldKey = keyParts.substring(splitIndex + 1);
           }
           console.log('parseTemplate: mainKey extracted',mainKey);
           console.log('parseTemplate: fieldKey extracted',fieldKey);
           if (! (Object.keys(mergeFields)).includes(mainKey) ) {
              mergeFields[mainKey] = {};
              console.log('parseTemplate: new object added extracted',mainKey);
           }
           (mergeFields[mainKey])[fieldKey] = {'token': keyItem};
           console.log('parseTemplate: specific token added',fieldKey);
            
        });
        console.log('parseTemplate: END / mergeFields initialized', mergeFields);
        return mergeFields;
    },
    getCurrentUser : function() {
        console.log('getUserId invoked');
		return $A.get("$SObjectType.CurrentUser");
	},
    getLabels : function(tokenKeys,component) {
        // WORK IN PROGRESS
        console.log("getLabels: START",tokenKeys);
        
        let labels = {};
        let tmpStr, tmpObj;
        let counter = 0;
        (Object.keys(tokenKeys)).forEach(function(tokenName){
            console.log("getLabels: processing key", "$Label." + tokenName);
            //console.log("getLabels: processing label", "v.techLabel" + counter);
            
            tmpStr = $A.getReference("$Label." + tokenName);
            component.set("v.techLabel" + counter, tmpStr);
             
            /*
            let techLabel = component.get("v.techLabel" + counter) || tokenName.substring(2);
            console.log('getLabels: label fetched cmp', techLabel);
            labels[tokenName.substring(2)] = techLabel;
            */
            /*
            let notFetched = true;
            let counter2 = 0;
            while (notFetched) {
              tmpStr = $A.getReference("$Label." + tokenName);
              component.set("v.techLabel", tmpStr);
                
              let techLabel = component.get("v.techLabel");
              console.log('getLabels: label fetched cmp', techLabel);
              if (techLabel) {
                 labels[tokenName.substring(2)] = techLabel;
                 console.log('getLabels: looping out');
                 notFetched = false;
              } else {
                  if (counter2 > 10) {
                      console.log('getLabels: looping out (10 iterations)');
                      notFetched = false;
                  } 
                  counter2 += 1;
                  console.log('getLabels: looping');
              } 
            }
            */
            counter += 1;
        });
          
        counter = 0;
        (Object.keys(tokenKeys)).forEach(function(tokenName){
            console.log("getLabels: reprocessing key", "$Label." + tokenName);
            //console.log("getLabels: processing label", "v.techLabel" + counter);
                
            let techLabel = component.get("v.techLabel" + counter) || tokenName.substring(2);
            console.log('getLabels: label fetched cmp', techLabel);
            labels[tokenName.substring(2)] = techLabel;
            
            counter += 1;
        });
            /*let labelValue2 = $A.get('Label.c.XXY_Test_Label', function(result){
            console.log('initConfig labelValue2 fetched',result);
            component.set("v.labelValue2",result);
            });*/
        
        console.log('getLabels: all label fetched', JSON.stringify(labels));
        //console.log('getLabels: final techObj fetched', JSON.stringify(component.get("v.techObj")));
        //console.log('getLabels: final techLabel fetched', component.get("v.techLabel"));
        //console.log('getLabels: final techLabel fetched', component.get("v.techLabel"));

        console.log("getLabels: END");
        return {"c":labels};
    },
    mergeFields : function(stringToMerge, tokenKeys, objectData) {
        console.log('mergeFields START');
        
        let tokenField;
        let keyRegex;
        console.log('mergeFields: stringToMerge to process', stringToMerge);
        console.log('mergeFields: objectData provided', JSON.stringify(objectData));
        (Object.keys(tokenKeys)).forEach(function(tokenName){
            console.log('mergeFields: processing tokenItem',tokenName);
            tokenField = tokenKeys[tokenName];
            console.log('mergeFields: tokenField set',tokenField);
            
            keyRegex = new RegExp(tokenField.token, 'g');
            console.log('mergeFields: keyRegex set', keyRegex);
            
            let nameParts = tokenName.split('.');
            let targetValue = null;
            if (nameParts.length > 1) {
                console.log('mergeFields: multipart field --> nameParts', nameParts);
                targetValue = objectData;
                nameParts.forEach(function(nameItem) {
                    console.log('mergeFields: iterating nameItem',nameItem);
                    if (targetValue) {
                        targetValue = targetValue[nameItem] || null;
                    }
                    console.log('mergeFields: multipart targetValue updated',targetValue);
                });
                console.log('mergeFields: multipart field set --> targetValue', targetValue);
            } else {
                targetValue = objectData[tokenName];
                console.log('mergeFields: single part field --> targetValue', targetValue);
            }
            
            
            stringToMerge = stringToMerge.replace(keyRegex,targetValue);
            console.log('mergeFields: stringToMerge updated',stringToMerge);
        });

        console.log('mergeFields END');
        return stringToMerge;
    },
    compareLists : function(subList, refList) {
        console.log('compareFieldLists START');
        console.log('compareFieldLists refList fetched',JSON.stringify(refList));
        let returnValue = true;
        subList.forEach(function(fieldItem){
            console.log('compareFieldLists processing fieldItem',fieldItem);
            if (! refList.includes(fieldItem)) {
                console.log('compareFieldLists false set');
                returnValue = false;
            }
        });
        console.log('compareFieldLists END',returnValue);
        return returnValue;
    },
    mergeUserFields : function(component, event, helper) {
        console.log('mergeUserFields: START');
        
        let mergeContext     = component.get("v.context");
        let userRecordFields = component.get("v.userRecordFields");
        if (userRecordFields) {
            console.log('mergeUserFields: userRecordFields fetched',JSON.stringify(userRecordFields));
            mergeContext.fetchUser = false;
            mergeContext.mergedTemplate = helper.mergeFields(mergeContext.mergedTemplate,
                                                             mergeContext.userKeys,
                                                             userRecordFields);
            console.log('mergeUserFields: mergedTemplate updated with User',mergeContext.mergedTemplate);
            
            component.set("v.fetchUser",false);
            
            if (mergeContext.fetchObject) {
                console.log('mergeUserFields: additional Object info required for merge');
                component.set("v.context",mergeContext);
            } else {
                console.log('mergeUserFields: merge completed');
                mergeContext.callback(mergeContext.mergedTemplate,null);
                return;
            }
        } else {
            console.error('mergeUserFields: User information retrieval error',component.get('v.userRecordError'));
            mergeContext.callback(null,component.get('v.userRecordError'));
            return;
        }
        //component.set("v.fetchUser",false);
        console.log('mergeUserFields: END');
    },
    mergeObjectFields : function(component, event, helper) {
        console.log('mergeObjectFields: START');
        
        let mergeContext       = component.get("v.context");
        let objectRecordFields = component.get("v.objectRecordFields");
        if (objectRecordFields) {
            console.log('mergeObjectFields: objectRecordFields fetched',JSON.stringify(objectRecordFields));
            mergeContext.fetchObject = false;
            mergeContext.mergedTemplate = helper.mergeFields(mergeContext.mergedTemplate,
                                                             mergeContext.objectKeys,
                                                             objectRecordFields);
            console.log('mergeObjectFields: mergedTemplate updated with Object',mergeContext.mergedTemplate);
            
            component.set("v.fetchObject",false);
            
            if (mergeContext.fetchUser) {
                console.log('mergeObjectFields: additional User info required for merge');
                component.set("v.context",mergeContext);
            } else {
                console.log('mergeObjectFields: merge completed');
                mergeContext.callback(mergeContext.mergedTemplate,null);
                return;
            }
        } else {
            console.error('mergeObjectFields: Object information retrieval error',component.get('v.objectRecordError'));
            mergeContext.callback(null,component.get('v.objectRecordError'));
            return;
        }
        //component.set("v.fetchObject",false);
        console.log('mergeObjectFields: END');
    },
    mergeAction : function(action,row,callback,component,helper) {
        console.log('mergeAction: START');
        
        /*
        console.log('mergeAction: component',component);
        console.log('mergeAction: component name',component.getName());
        console.log('mergeAction: component global ID',component.getGlobalId());
        */
        
        let actionStr = JSON.stringify(action);
        console.log('mergeAction: action stringified',actionStr);
        
        helper.mergeTemplate(
            actionStr,
            row,
            function(result,error) {
                  console.log('mergeAction result from merge',result);
                  if (result) {
                      let resultJson = JSON.parse(result);
                      console.log('mergeAction: result parsed',resultJson);

                      let eventToTrigger = $A.get(resultJson.name);
                      if (eventToTrigger) {
                          if (resultJson.params) {
                              eventToTrigger.setParams(resultJson.params);
                              console.log('mergeAction: event params set',resultJson.params);
                          }
                          console.log('mergeAction: triggering event',eventToTrigger);
                          eventToTrigger.fire();
                          if (callback) callback(resultJson,null);
                      } else {
                          console.error('mergeAction: triggering merge error notification',
                                        resultJson.name + ' event not found');
                          /*component.find('notifLib').showNotice({
                             "variant": "error",
                             "header": "Error in action merge !",
                             "message": resultJson.name + ' event not found'
                          });*/
                          if (callback) callback(null,resultJson.name + ' event not found');
                      }
                  } else {
                      console.error('mergeAction: triggering merge error notification',
                                    JSON.stringify(error));
                      /*component.find('notifLib').showNotice({
                         "variant": "error",
                         "header": "Error in action merge !",
                         "message": JSON.stringify(error)
                      });*/
                      if (callback) callback(null,error);
                  }
            },
            component,
            helper
        );
        console.log('triggerAction: END');
    }
})