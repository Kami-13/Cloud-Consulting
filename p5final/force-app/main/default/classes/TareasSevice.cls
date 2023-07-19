public with sharing class TareasSevice {
	
	public class Tareas{
        @AuraEnabled
        public Map<String,List<Task__c>> id_proyecto_tareas_mapa;
        
        public Tareas(Map<String,List<Task__c>> id_proyecto_tareas_mapa){
            this.id_proyecto_tareas_mapa = id_proyecto_tareas_mapa;
        }
    }
    
    // = '005Do000001lipbIAA'
    public Tareas obtener_Tareas(){
        
        List<Task__c> tareas = [SELECT Name, Status__c, Worked_Hours__c, Assigned_Hours__c,
                                       Project__r.Name  
                                FROM Task__c
                                WHERE Project_Resource__r.Resource__c = :UserInfo.getUserId()
                                	  AND
                                	  Status__c != 'Completed'
                                ORDER BY Status__c DESC];
        
        Map<String,List<Task__c>> id_proyecto_tareas_mapa = new Map<String,List<Task__c>>();
        for(Task__c t: tareas){
            if(!id_proyecto_tareas_mapa.containsKey(t.Project__r.Name)){
                id_proyecto_tareas_mapa.put(t.Project__r.Name, new List<Task__c>{t});
            }else{
                id_proyecto_tareas_mapa.get(t.Project__r.Name).add(t);
            }
        }
        
        Tareas instanciada = new Tareas(id_proyecto_tareas_mapa);
        
        return instanciada;
    }
    
    public static Boolean registrar_Horas(String strJSON){
        
        Map<String, Object> objeto_ListaJSON = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        
        Task__c tarea = [SELECT Status__c, Worked_Hours__c
                         FROM Task__c
                         WHERE id = :(Id)objeto_ListaJSON.get('Id')];

        tarea.Status__c = 'In Progress';
        
        tarea.Worked_Hours__c += Integer.valueOf(objeto_ListaJSON.get('Worked_Hours__c'));
        
        update tarea;
        
        return true;
    }
    
    public static Boolean actualizar_estado(String strJSON){
        
        Map<String, Object> objeto_ListaJSON = (Map<String, Object>)JSON.deserializeUntyped(strJSON);
        
        Task__c tarea = [SELECT Status__c, Worked_Hours__c
                         FROM Task__c
                         WHERE id = :(Id)objeto_ListaJSON.get('Id')];
        
        tarea.Status__c = 'Completed';

        tarea.Worked_Hours__c += Integer.valueOf(objeto_ListaJSON.get('Worked_Hours__c'));
        
        update tarea;
        
        return true;
    }
        
        
        
        
        
        
        
        
        
        
        
        
        
}