global class LineChatManagementScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        SLA_schedule_time__c scheduleTimeCustom = SLA_schedule_time__c.getInstance();
		Integer scheduleTime = Integer.valueOf(scheduleTimeCustom.get('schedule_time__c'));
		
		DateTime myDateTime = System.now().addMinutes(scheduleTime == null? 5: scheduleTime);
		database.executebatch(new LineChatManagementBatch());


		String day = string.valueOf(myDateTime.day());
        String month = string.valueOf(myDateTime.month());
        String hour = string.valueOf(myDateTime.hour());
        String minute = string.valueOf(myDateTime.minute());
        String second = '0';
        String year = string.valueOf(myDateTime.year());

        if (Integer.valueOf(year) + 543 >= 3000) {
			Integer ny = Integer.valueOf(year) - 543;
			year = String.valueOf(ny);
		}

        String strJobName = 'Job-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year + '_LineChatManagementSchedule';
		String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
		System.debug('strJobName : '+ strJobName);
		if(!Test.isRunningTest()) {
			System.schedule(strJobName, strSchedule, new LineChatManagementScheduler());
		}

		List<CronTrigger> jobNameToAborts = [SELECT CronJobDetail.Name FROM  CronTrigger where NextFireTime = null and CronJobDetail.JobType = '7'and CronJobDetail.Name like '%_LiveChatManagementSchedule%' limit 100];
		System.debug('strJobNameToAborts : ' + jobNameToAborts);
		
		for(CronTrigger job : jobNameToAborts){
			GlobalUtility.abortScheduledJob(String.valueOf(job.CronJobDetail.Name));
		}
		
    }
}