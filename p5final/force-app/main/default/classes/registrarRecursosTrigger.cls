public with sharing class registrarRecursosTrigger {
    
    public class Estructuras_Validacion {
        Set<Id> recursos_Id_Set;
        List<User> recursos_Completos_Lista;
        Map<Id,User> recursos_Completos_Mapa;
        Map<Id,List<Project_Resource__c>> recursos_Proyectos_Mapa;
        
        public Estructuras_Validacion(Set<Id> recursos_Id_Set, List<User> recursos_Completos_Lista, Map<Id,User> recursos_Completos_Mapa, Map<Id,List<Project_Resource__c>> recursos_Proyectos_Mapa){
            this.recursos_Id_Set = recursos_Id_Set;
            this.recursos_Completos_Lista = recursos_Completos_Lista; 
            this.recursos_Completos_Mapa = recursos_Completos_Mapa;
            this.recursos_Proyectos_Mapa = recursos_Proyectos_Mapa;
        }
    }
    
    public static void filtrar(List<Project_Resource__c> TN, Boolean TN_isIn, Boolean TN_isUp, Integer TN_size){
        Set<Id> proyectos_Id = new Set<Id>();
        Set<Id> recursos_Id = new Set<Id>();
        Map<Id,List<Project_Resource__c>> id_proyectos_pr_asignados_mapa = new Map<Id,List<Project_Resource__c>>();
        for(Project_Resource__c pr: TN){
            proyectos_Id.add(pr.Project__c);
            recursos_Id.add(pr.Resource__c);
            if(id_proyectos_pr_asignados_mapa.containsKey(pr.Project__c)){
               id_proyectos_pr_asignados_mapa.get(pr.Project__c).add(pr);
            }else{
                id_proyectos_pr_asignados_mapa.put(pr.Project__c, new List<Project_Resource__c>{pr}); 
            }
        }
        
        List<Project__c> proyecto_completos = [SELECT (SELECT Role__c, Quantity_Of_Hours__c  
                                       				   FROM Project_Roles__r),
                                               		  (SELECT Resource__c, Resource__r.UserRole.Name, 
                                                              Project__c, Hours_Assigned_Resource__c  
                                       				   FROM Project_Resources__r)
                                               FROM Project__c
                                               WHERE Id IN :proyectos_Id];
        
        Map<Id,Map<String,Integer>> id_proyecto_rol_horas_alocadas_mapa = new Map<Id,Map<String,Integer>>();
        for(Project__c p: proyecto_completos){
            if(!p.Project_Resources__r.isEmpty()){
                Map<String,Integer> rol_horas_alocadas_mapa = new Map<String,Integer>();
                for(Project_Resource__c pr: p.Project_Resources__r){
                    if(!rol_horas_alocadas_mapa.containsKey(pr.Resource__r.UserRole.Name)){
                        rol_horas_alocadas_mapa.put(pr.Resource__r.UserRole.Name, pr.Hours_Assigned_Resource__c.intValue());
                    }else{
                        rol_horas_alocadas_mapa.put(pr.Resource__r.UserRole.Name, 
                                                    pr.Hours_Assigned_Resource__c.intValue() + 
                                                    rol_horas_alocadas_mapa.get(pr.Resource__r.UserRole.Name));
                    }
                }
                id_proyecto_rol_horas_alocadas_mapa.put(p.Id, rol_horas_alocadas_mapa);
            }     
        }
        
        
        List<User> recursos_completos = [SELECT UserRole.Name
                                         FROM User
                                         WHERE Id IN :recursos_Id];
        Map<Id,User> recursos_completos_mapa = new Map<Id,User>(recursos_completos);
        
        Map<Id,Map<String,Integer>> id_proyecto_rol_horas_asignadas_mapa = new Map<Id,Map<String,Integer>>();
        for(Id id_p: proyectos_Id){
            Map<String,Integer> rol_horas_asignadas_mapa = new Map<String,Integer>();
            for(Project_Resource__c pr: TN){
                if(pr.Project__c == id_p){
                    if(!rol_horas_asignadas_mapa.containsKey(recursos_completos_mapa.get(pr.Resource__c).UserRole.Name)){
                    	rol_horas_asignadas_mapa.put(recursos_completos_mapa.get(pr.Resource__c).UserRole.Name, 
                                                     pr.Hours_Assigned_Resource__c.intValue());
                	}else{
                    	rol_horas_asignadas_mapa.put(recursos_completos_mapa.get(pr.Resource__c).UserRole.Name, 
                                                     pr.Hours_Assigned_Resource__c.intValue() + 
                                                     rol_horas_asignadas_mapa.get(pr.Resource__r.UserRole.Name));
                	}
                }
            }
            id_proyecto_rol_horas_asignadas_mapa.put(id_p, rol_horas_asignadas_mapa);     
        }
        
        
        Map<Id,List<Project_Role__c>> ip_proyecto_pr_mapa = new Map<Id,List<Project_Role__c>>();
        for(Project__c p: proyecto_completos){
            ip_proyecto_pr_mapa.put(p.Id, p.Project_Roles__r);
        }
        
        Integer bandera = 0;
        for(Id id_p: proyectos_Id){
            for(Project_Role__c pr: ip_proyecto_pr_mapa.get(id_p)){
                if(id_proyecto_rol_horas_alocadas_mapa.containskey(id_p)){
                    if(id_proyecto_rol_horas_alocadas_mapa.get(id_p).containskey(pr.Role__c) &&
                       id_proyecto_rol_horas_asignadas_mapa.get(id_p).containskey(pr.Role__c)){
                        if((id_proyecto_rol_horas_alocadas_mapa.get(id_p).get(pr.Role__c) + 
                        	id_proyecto_rol_horas_asignadas_mapa.get(id_p).get(pr.Role__c)) > 
                        	pr.Quantity_Of_Hours__c.intValue()){
                        	id_proyectos_pr_asignados_mapa.get(id_p)[0].addError('Assigned hours have been exceeded');
                        	bandera++;
                         }else if(id_proyecto_rol_horas_asignadas_mapa.get(id_p).containskey(pr.Role__c)){
                                  if(id_proyecto_rol_horas_asignadas_mapa.get(id_p).get(pr.Role__c) > 
                    	 		  	 pr.Quantity_Of_Hours__c.intValue()){
                                     id_proyectos_pr_asignados_mapa.get(id_p)[0].addError('Assigned hours have been exceeded');
                         		  	 bandera++;     
                                  }   
                         }
                    }
                }else if(id_proyecto_rol_horas_asignadas_mapa.get(id_p).containskey(pr.Role__c)){
                         if(id_proyecto_rol_horas_asignadas_mapa.get(id_p).get(pr.Role__c) > 
                    	 	pr.Quantity_Of_Hours__c.intValue()){
                            id_proyectos_pr_asignados_mapa.get(id_p)[0].addError('Assigned hours have been exceeded');
                            bandera++;     
                         }  
                } 
             }
        }
        
        if(bandera == 0){
            Recursos_Validacion(TN, TN_isIn, TN_isUp, TN_size);
        }
        
    }
    
    public static Estructuras_Validacion obtener_Estructuras(List<Project_Resource__c> TN){
        	List<Id> recursos_Id_Lista = new List<Id>();
            for(Project_Resource__c pr: TN){
                recursos_Id_Lista.add(pr.Resource__c);
            }
    		Set<Id> recursos_Id_Set = new Set<Id>(recursos_Id_Lista);
        	List<User> recursos_Completos_Lista = [SELECT (SELECT Date_Start__c, Date_End__c, Project__c
                                                           FROM Project_Resources__r)
                                                   FROM User
                                                   WHERE Id IN :recursos_Id_Set];
        
        	Map<Id,User> recursos_Completos_Mapa = new Map<Id,User>(recursos_Completos_Lista);
        	Map<Id,List<Project_Resource__c>> recursos_Proyectos_Mapa = new Map<Id,List<Project_Resource__c>>();
            for(User recurso: recursos_Completos_Lista){
            	   recursos_Proyectos_Mapa.put(recurso.Id, recurso.Project_Resources__r);
            }
        
        	Estructuras_Validacion estructuras = new Estructuras_Validacion(recursos_Id_Set, recursos_Completos_Lista, recursos_Completos_Mapa, recursos_Proyectos_Mapa);
        	
        	return estructuras;
    }
    
    public static void Recursos_Validacion(List<Project_Resource__c> TN, Boolean TN_isIn, Boolean TN_isUp, Integer TN_size){
 
            if(TN_isIn && (TN_size==1)){
            		Estructuras_Validacion estructuras = obtener_Estructuras(TN);
                    for(Project_Resource__c pr: TN){
                        for(Project_Resource__c pr_completos: estructuras.recursos_Proyectos_Mapa.get(pr.Resource__c)){
                            if(!((pr_completos.Date_Start__c < pr.Date_Start__c && pr_completos.Date_End__c < pr.Date_Start__c) || (pr_completos.Date_Start__c > pr.Date_End__c && pr_completos.Date_End__c > pr.Date_End__c))){
                                   pr.addError('¡This resource can not be inserted! Your allocation date:\n' + String.valueOf(pr.Date_Start__c) + ' - ' + String.valueOf(pr.Date_End__c) + '\nIs overlaping with an allocated date assigned to another project:\n' + String.valueOf(pr_completos.Date_Start__c) + ' - ' + String.valueOf(pr_completos.Date_End__c));
                                   //VariablesEstructuras.set_recursos_No_Insertados(pr);
                                   break;
                            }
                        }   
                    }
        
        			//VariablesEstructuras.set_trigger_Finalizo(True);    
            }else if(TN_isUp && (TN_size==1)){
                	Estructuras_Validacion estructuras = obtener_Estructuras(TN);
                    for(Project_Resource__c pr: TN){
                        for(Project_Resource__c pr_completos: estructuras.recursos_Proyectos_Mapa.get(pr.Resource__c)){
                            if(!((pr_completos.Date_Start__c < pr.Date_Start__c && pr_completos.Date_End__c < pr.Date_Start__c) || (pr_completos.Date_Start__c > pr.Date_End__c && pr_completos.Date_End__c > pr.Date_End__c)) && !(pr.Id == pr_completos.Id)){
                                   pr.addError('¡This resource can not be update! Your allocation date:\n' + String.valueOf(pr.Date_Start__c) + ' - ' + String.valueOf(pr.Date_End__c) + '\nIs overlaping with an allocated date assigned to another project:\n' + String.valueOf(pr_completos.Date_Start__c) + ' - ' + String.valueOf(pr_completos.Date_End__c));
                                   //VariablesEstructuras.set_recursos_No_Insertados(pr);
                                   break;
                            }
                        }   
                    }
        
        			//VariablesEstructuras.set_trigger_Finalizo(True);
            }else if(TN_size > 1){
                	Estructuras_Validacion estructuras = obtener_Estructuras(TN);
                	List<Project_Resource__c> erroneas = new List<Project_Resource__c>();
                	for(Project_Resource__c pr: TN){
                        for(Project_Resource__c pr_completos: estructuras.recursos_Proyectos_Mapa.get(pr.Resource__c)){
                            if(!((pr_completos.Date_Start__c < pr.Date_Start__c && pr_completos.Date_End__c < pr.Date_Start__c) || (pr_completos.Date_Start__c > pr.Date_End__c && pr_completos.Date_End__c > pr.Date_End__c)) && !(pr.Id == pr_completos.Id)){
                                    //pr.addError('¡This resource can not be update! Your allocation date:\n' + String.valueOf(pr.Date_Start__c) + ' - ' + String.valueOf(pr.Date_End__c) + '\nIs overlaping with an allocated date assigned to another project:\n' + String.valueOf(pr_completos.Date_Start__c) + ' - ' + String.valueOf(pr_completos.Date_End__c));
                                    erroneas.add(pr);
                                	break;
                            }
                        }   
                    }
                
                	String[] errores = new String[0];
                    if(erroneas.size()>0){
                        Set<Id> erroneas_recursos_Id = new Set<Id>();
                        for(Project_Resource__c pr: erroneas){
                            erroneas_recursos_Id.add(pr.Resource__c);
                        }
                        
                        List<User> recursos_Nombre_Lista = [SELECT Name
                                      	 					FROM User
                                      	 					WHERE Id IN :erroneas_recursos_Id];
                        
                        Map<Id,User> recursos_Nombre_Mapa = new Map<Id,User>(recursos_Nombre_Lista);
                        
                        for(Project_Resource__c pr: erroneas){
                            errores.add('You can not allocate the resource '
                                       	 + recursos_Nombre_Mapa.get(pr.Resource__c).Name
                                       	 + ' on the indicated date: '
                                         + pr.Date_Start__c + ' - '
                                         + pr.Date_End__c + ' - \n');
                        }
                        
                        erroneas[0].addError(String.join(errores, ', '));
                    }
            }
        	
    }
    
}

















































/***
 public with sharing class registrarRecursosTrigger {
    
    public class Estructuras_Validacion {
        Set<Id> recursos_Id_Set;
        List<User> recursos_Completos_Lista;
        Map<Id,User> recursos_Completos_Mapa;
        Map<Id,List<Project_Resource__c>> recursos_Proyectos_Mapa;
        
        public Estructuras_Validacion(Set<Id> recursos_Id_Set, List<User> recursos_Completos_Lista, Map<Id,User> recursos_Completos_Mapa, Map<Id,List<Project_Resource__c>> recursos_Proyectos_Mapa){
            this.recursos_Id_Set = recursos_Id_Set;
            this.recursos_Completos_Lista = recursos_Completos_Lista; 
            this.recursos_Completos_Mapa = recursos_Completos_Mapa;
            this.recursos_Proyectos_Mapa = recursos_Proyectos_Mapa;
        }
    }
    
    public static Estructuras_Validacion obtener_Estructuras(List<Project_Resource__c> TN){
        	List<Id> recursos_Id_Lista = new List<Id>();
            for(Project_Resource__c pr: TN){
                recursos_Id_Lista.add(pr.Resource__c);
            }
    		Set<Id> recursos_Id_Set = new Set<Id>(recursos_Id_Lista);
        	List<User> recursos_Completos_Lista = [SELECT (SELECT Date_Start__c, Date_End__c, Project__c
                                                           FROM Project_Resources__r)
                                                   FROM User
                                                   WHERE Id IN :recursos_Id_Set];
        
        	Map<Id,User> recursos_Completos_Mapa = new Map<Id,User>(recursos_Completos_Lista);
        	Map<Id,List<Project_Resource__c>> recursos_Proyectos_Mapa = new Map<Id,List<Project_Resource__c>>();
            for(User recurso: recursos_Completos_Lista){
            	   recursos_Proyectos_Mapa.put(recurso.Id, recurso.Project_Resources__r);
            }
        
        	Estructuras_Validacion estructuras = new Estructuras_Validacion(recursos_Id_Set, recursos_Completos_Lista, recursos_Completos_Mapa, recursos_Proyectos_Mapa);
        	
        	return estructuras;
    }
    
    public static void Recursos_Validacion(List<Project_Resource__c> TN, Boolean TN_isIn, Boolean TN_isUp){
 
            if(TN_isIn){
            		Estructuras_Validacion estructuras = obtener_Estructuras(TN);
                    for(Project_Resource__c pr: TN){
                        for(Project_Resource__c pr_completos: estructuras.recursos_Proyectos_Mapa.get(pr.Resource__c)){
                            if(!((pr_completos.Date_Start__c < pr.Date_Start__c && pr_completos.Date_End__c < pr.Date_Start__c) || (pr_completos.Date_Start__c > pr.Date_End__c && pr_completos.Date_End__c > pr.Date_End__c))){
                                   pr.addError('¡This resource can not be inserted! Your allocation date:\n' + String.valueOf(pr.Date_Start__c) + ' - ' + String.valueOf(pr.Date_End__c) + '\nIs overlaping with an allocated date assigned to another project:\n' + String.valueOf(pr_completos.Date_Start__c) + ' - ' + String.valueOf(pr_completos.Date_End__c));
                                   VariablesEstructuras.set_recursos_No_Insertados(pr);
                                   break;
                            }
                        }   
                    }
        
        			VariablesEstructuras.set_trigger_Finalizo(True);    
            }else if(TN_isUp){
                	Estructuras_Validacion estructuras = obtener_Estructuras(TN);
                    for(Project_Resource__c pr: TN){
                        for(Project_Resource__c pr_completos: estructuras.recursos_Proyectos_Mapa.get(pr.Resource__c)){
                            if(!((pr_completos.Date_Start__c < pr.Date_Start__c && pr_completos.Date_End__c < pr.Date_Start__c) || (pr_completos.Date_Start__c > pr.Date_End__c && pr_completos.Date_End__c > pr.Date_End__c)) && !(pr.Id == pr_completos.Id)){
                                   pr.addError('¡This resource can not be update! Your allocation date:\n' + String.valueOf(pr.Date_Start__c) + ' - ' + String.valueOf(pr.Date_End__c) + '\nIs overlaping with an allocated date assigned to another project:\n' + String.valueOf(pr_completos.Date_Start__c) + ' - ' + String.valueOf(pr_completos.Date_End__c));
                                   VariablesEstructuras.set_recursos_No_Insertados(pr);
                                   break;
                            }
                        }   
                    }
        
        			VariablesEstructuras.set_trigger_Finalizo(True);
            }
        	
    }
    
}
 ***/