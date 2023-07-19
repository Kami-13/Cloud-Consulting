public with sharing class ProjectsList {
    
    @AuraEnabled(cacheable=True)
    public static Map<String, List<Project__c>> getProjectsByUser(String userId) {
        Map<String, List<Project__c>> projectMap = new Map<String, List<Project__c>>();
        
        List<Project__c> projectManagerProjects = [SELECT Id, Name, Status__c, Date_Start__c, Date_End__c, Squad_Lead__c, 
                                                          Squad_Lead__r.Name
                                                   FROM Project__c
                                                   WHERE Project_Manager__c = :userId
                                                   ORDER BY Date_Start__c DESC];
        
        projectMap.put('projectManagerProjects', projectManagerProjects);
        
        List<Project__c> squadLeadProjects = [SELECT Id, Name, Status__c, Date_Start__c, Date_End__c, Project_Manager__c,
                                                     Squad_Lead__c
                                              FROM Project__c
                                              WHERE Squad_Lead__c = :userId
                                              ORDER BY Date_Start__c DESC];
        
        projectMap.put('squadLeadProjects', squadLeadProjects);                                       
        
        return projectMap;  
    }
    
    
    @AuraEnabled(cacheable=True)
    public static Map<Id, List<Task__c>> getTaskByUser(String userId) {
        Map<Id, List<Task__c>> taskMap = new Map<Id, List<Task__c>>();
        
        List<Task__c> tareas_Lista = [SELECT Name, Project_Resource__r.Project__c, 
                                      		 Project_Resource__r.Project__r.Name
                                      FROM Task__c
                                      WHERE Project_Resource__c = :userId
                                      ORDER BY Date_Start__c DESC];
        
        if(!tareas_Lista.isEmpty()){
        	for(Task__c t: tareas_Lista){
                if(!taskMap.containsKey(t.Project_Resource__r.Project__c)){
                    taskMap.put(t.Project_Resource__r.Project__c, new List<Task__c>{t});
                }else{
                    taskMap.get(t.Project_Resource__r.Project__c).add(t);            
                }
        	}    
        }
                        
        return taskMap;     
    }
    
    @AuraEnabled(cacheable=True)
    public static List<Application__c> getVacationByUser(String userId) {
        
        List<Application__c> vacaciones_Lista = [SELECT Request_Description__c, Request_Status__c, Request_Date_End__c, Request_Date_Start__c
                                      		 	 FROM Application__c
                                      		 	 WHERE Project_Resource__r.Resource__c = :userId
                                      		 	 ORDER BY Request_Date_Start__c DESC];        
        return vacaciones_Lista;     
    }
}