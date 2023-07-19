public with sharing class TaskAssignationService {
    
    public static Boolean registrar_tareas(String strJSON){
        List<Task__c> tareas_ListaJSON = (List<Task__c>)JSON.deserialize(strJSON, List<Task__c>.class);
        insert tareas_ListaJSON;
        return true;
    }
    
    public class Proyecto_Recursos_Tareas{
        @AuraEnabled
        public List<Project_Resource__c> proyecto_recursos_lista;
        @AuraEnabled
        public Project__c proyecto;
        @AuraEnabled
        public List<Task__c> tareas;
        
        public proyecto_recursos_tareas(List<Project_Resource__c> proyecto_recursos_lista,
                                        Project__c proyecto, List<Task__c> tareas){
        	this.proyecto_recursos_lista = proyecto_recursos_lista;
            this.proyecto = proyecto;
            this.tareas = tareas;
        }
    }
    
    public Proyecto_Recursos_Tareas obtener_Proyecto_Recursos_Tarea(Id proId){
        
        Project__c pro = [SELECT Name, Date_Start__c, Date_End__c, 
                          		 Status__c
                          FROM Project__c
                          WHERE Id = :proId];
        
        List<Project_Resource__c> proyecto_recursos_lista = [SELECT Date_Start__c, Date_End__c, 
                                                              		Hours_Assigned_Resource__c,
                                                             		Resource__c, Resource__r.Name
                                                             FROM Project_Resource__c
                                                             WHERE Project__c = :proId];
        
        List<Task__c> tareas = [SELECT Date_Start__c, Date_End__c,
                                	   Project_Resource__c, Project_Resource__r.Project__c,
                                	   Project_Resource__r.Resource__c
                                FROM Task__c
                                WHERE Project_Resource__r.Project__c = :proId];
        
        
        Proyecto_Recursos_Tareas instanciada = new Proyecto_Recursos_Tareas(proyecto_recursos_lista, pro, tareas);
        
        return instanciada;
    }
}