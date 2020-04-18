trigger TaskTrigger on Task (after insert) {
    String whatId;
    String taskId;
    for (Task task : Trigger.new) {
        whatId = task.WhatId;
        taskId = task.Id;
        // System.debug('taskId='+taskId);
        // System.debug('whatId='+whatId);      
    }
    TaskTriggerHandler.TaskTrigger(whatId, taskId);
}