public with sharing class asignarSquadLeadTrigger {
    public static void filtrar(List<Project__c> TN, List<Project__c> TO){
        List<Project__c> proyectos = new List<Project__c>();
        Map<Id,Project__c> proyectos_o_mapa = new Map<Id,Project__c>(TO);
        List<Project__c> proyectos_completos = [SELECT (SELECT Id, Resource__c
                                                        FROM Project_Resources__r)
                                                FROM Project__c
                                                WHERE Id IN : TN];
        Map<Id, List<Project_Resource__c>> proyectos_id_pr_mapa = new Map<Id, List<Project_Resource__c>>();
        for(Project__c p: proyectos_completos){
            proyectos_id_pr_mapa.put(p.Id,p.Project_Resources__r);
        }
        for(Project__c p: TN){
            if(proyectos_o_mapa.get(p.Id).Squad_Lead__c == null && p.Squad_Lead__c != null){
                if(!proyectos_id_pr_mapa.get(p.Id).isEmpty()){
                    Integer bandera = 0;
                    for(Project_Resource__c pr: proyectos_id_pr_mapa.get(p.Id)){
                        if(p.Squad_Lead__c == pr.Resource__c){
                            bandera++;
                            break;
                        }
                    }
                    if(bandera==0){
                        p.addError('This resource can not be assigned because it is not allocated to the project');
                    }
                }else{
                    p.addError('To select a Squad Lead, first allocated resources to the project');
                }
            }else if(proyectos_o_mapa.get(p.Id).Squad_Lead__c != null){
                if((proyectos_o_mapa.get(p.Id).Squad_Lead__c != p.Squad_Lead__c) && p.Squad_Lead__c != null){
                	if(!proyectos_id_pr_mapa.get(p.Id).isEmpty()){
                        Integer bandera = 0;
                        for(Project_Resource__c pr: proyectos_id_pr_mapa.get(p.Id)){
                            if(p.Squad_Lead__c == pr.Resource__c){
                                bandera++;
                                break;
                            }
                        }
                        if(bandera==0){
                            p.addError('This resource can not be assigned because it is not allocated to the project');
                        }
                	}else{
                    		p.addError('To select a Squad Lead, first allocated resources to the project');
                	}
                }
            }
        }
    }
}