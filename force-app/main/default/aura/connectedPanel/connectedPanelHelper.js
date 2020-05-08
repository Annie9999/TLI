/*
Copyright 2016 salesforce.com, inc. All rights reserved.

Use of this software is subject to the salesforce.com Developerforce Terms of Use and other applicable terms that salesforce.com may make available, as may be amended from time to time. You may not decompile, reverse engineer, disassemble, attempt to derive the source code of, decrypt, modify, or create derivative works of this software, updates thereto, or any part thereof. You may not use the software to engage in any development activity that infringes the rights of a third party, including that which interferes with, damages, or accesses in an unauthorized manner the servers, networks, or other properties or services of salesforce.com or any third party.

WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. IN NO EVENT SHALL SALESFORCE.COM HAVE ANY LIABILITY FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO, DIRECT, INDIRECT, SPECIAL, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR DAMAGES BASED ON LOST PROFITS, DATA OR USE, IN CONNECTION WITH THE SOFTWARE, HOWEVER CAUSED AND, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, WHETHER OR NOT YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
*/

({
  // log a task for the call
  logCall : function(cmp, callback) {
    console.log('logCall');
    var recordId = cmp.get('v.recordId'); 
    var accountId; //= cmp.get('v.account').Id;

    var whoId ;//= cmp.get('v.recordId'); // WhoId related to contact or lead
    var whatId ;
    var prefix = recordId.substring(0,3)
    // if(accountId === undefined || accountId === null) {        
        // console.log('accountId = undifined');
        var args = {
            apexClass : 'SoftphoneContactSearchController',
            methodName : 'getWhoId',
            methodParams : 'recordId=' + recordId,
            //methodParams : 'name=' +  cmp.get('v.recordName'),
            callback : function(result) {
                if (result.success) {
                    var results = JSON.parse(result.returnValue.runApex);
                    console.log(results); 
                    console.log('recordId='+results[0].Id+', accountId='+results[0].AccountId+', contactId='+results[0].ContactId); 
                    whatId = results[0].Id; // caseId or contactId or leadId
					console.log('WhatId=', whatId);
                 
                    if(results[0].ContactId != null & results[0].ContactId != undefined){
                        whoId = results[0].ContactId;
                        accountId = results[0].AccountId;
                    }else if(prefix == '00Q'){
                        whoId = recordId;
                    }
                    
                    // if (whoId.substring(0,3) == '00Q') { // if whoId is leadId
                    //     recordId = (results[0].Service_Request__c === undefined) ? '' : results[0].Service_Request__c;
                    // }

                } else {                                                                                                                                     
                    throw new Error('Unable to perform a search using Open CTI. Contact your admin.');
                }
            }
        };
        sforce.opencti.runApex(args);
      
    // }
    
    setTimeout(function(){
        if(whoId == whatId) {
            whatId = accountId;
        }

        console.log('WhatId=', whatId);
        console.log('WhoId=', whoId);

        var component = cmp;
        if (typeof cmp.get('v.recordId') !== 'undefined') { // Yu
            if (cmp.get('v.recordId').length == 0 || cmp.get('v.showDialPad')){
                callback();
            } else {
                // console.log('createLog');
                var today = new Date();
                var date = today.getDate()+'/'+(today.getMonth()+1)+'/'+today.getFullYear();

                var hour    = today.getHours();
                var minute  = today.getMinutes();
                var second  = today.getSeconds(); 
                if(hour.toString().length == 1) {hour = '0'+hour;}
                if(minute.toString().length == 1) {minute = '0'+minute;}
                if(second.toString().length == 1) {second = '0'+second;}   
                var time = hour + ':' + minute + ':' + second;
                var dateTime = date+' '+time;

                cmp.find("ticker").getDurationInSeconds(function(duration) {
                    sforce.opencti.saveLog({
                        value : {
                            entityApiName : 'Task',
                            WhoId : whoId,
                            CallDisposition : 'Internal',
                            CallObject : 'DemoCall',
                            Description : component.find('note').get('v.value'),
                            Subject : 'Call Log : '+dateTime,
                            Priority : 'Normal',
                            Status : 'Completed',
                            CallDurationInSeconds : duration,
                            CallType : cmp.get('v.callType'),
                            Type : 'Call',
                            WhatId : whatId,
                            ActivityDate : new Date()
                        },
                        callback : callback
                    });
                })
            }
        } else {
            callback();
        }
    },2000);     
  }

})